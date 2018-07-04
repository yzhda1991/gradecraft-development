@gradecraft.directive "learningObjectivesShow", ["LearningObjectivesService", "CourseService", "SortableService", "$q", (LearningObjectivesService, CourseService, SortableService, $q) ->
  LearningObjectivesShowCtrl = [() ->
    vm = this
    vm.loading = true
    vm.sortable = SortableService
    vm.students = CourseService.students
    vm.objective = LearningObjectivesService.objective
    vm.linkedAssignments = LearningObjectivesService.linkedAssignments
    vm.cumulativeOutcomes = LearningObjectivesService.cumulativeOutcomes

    vm.hasLinkedAssignments = () -> _.some(vm.linkedAssignments)
    vm.termFor = (term) -> LearningObjectivesService.termFor(term)

    vm.cumulativeOutcome = (studentId) ->
      _studentId = if angular.isDefined(studentId) then studentId else @studentId
      _.find(LearningObjectivesService.cumulativeOutcomes, { user_id: parseInt(_studentId) })

    vm.progress = (studentId) ->
      co = vm.cumulativeOutcome(parseInt(studentId))
      return "Not started" unless co?
      co.status

    vm.percent_complete = (studentId) ->
      co = vm.cumulativeOutcome(parseInt(studentId))
      co.percent_complete

    vm.observedOutcomes = (studentId) ->
      _studentId = if angular.isDefined(studentId) then studentId else @studentId
      co = vm.cumulativeOutcome(parseInt(_studentId))
      return unless co?
      LearningObjectivesService.observedOutcomesFor(co.id)

    vm.gradeExists = (studentId, assignmentId) ->
      oo = vm.observedOutcomeFor(studentId, assignmentId)
      oo? and oo.outcome_visible

    vm.gradePath = (studentId, assignmentId) ->
      oo = vm.observedOutcomeFor(studentId, assignmentId)
      "/grades/#{oo.grade_id}"

    vm.showPath = (studentId) ->
      "/learning_objectives/objectives/#{@objectiveId}?student_id=#{studentId}"

    vm.observedOutcomeFor = (studentId, assignmentId) ->
      oo = vm.observedOutcomes(studentId)
      return unless oo?
      _.find(oo, { assignment_id: assignmentId })

    services(@objectiveId, @studentId).then(() -> vm.loading = false)
  ]

  services = (objectiveId, studentId) ->
    promises = [LearningObjectivesService.getObjective(objectiveId)]
    promises.push(LearningObjectivesService.getOutcomesForObjective(objectiveId, studentId)) if studentId?
    promises.push(CourseService.getStudents(), LearningObjectivesService.getOutcomesForObjective(objectiveId)) if !studentId
    $q.all(promises)

  {
    scope:
      studentId: "@"
      objectiveId: "@"
    bindToController: true
    controller: LearningObjectivesShowCtrl
    controllerAs: "loShowCtrl"
    templateUrl: "learning_objectives/objectives/show.html"
  }
]
