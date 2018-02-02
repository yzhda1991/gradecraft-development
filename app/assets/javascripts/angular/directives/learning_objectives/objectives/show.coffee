@gradecraft.directive "learningObjectivesShow", ["LearningObjectivesService", "CourseService", "$q", (LearningObjectivesService, CourseService, $q) ->
  LearningObjectivesShowCtrl = [() ->
    vm = this
    vm.loading = true
    vm.students = CourseService.students
    vm.objective = LearningObjectivesService.objective
    vm.linkedAssignments = LearningObjectivesService.linkedAssignments
    vm.cumulativeOutcomes = LearningObjectivesService.cumulativeOutcomes

    vm.cumulativeOutcome = (studentId) ->
      _.find(LearningObjectivesService.cumulativeOutcomes, { user_id: studentId })

    vm.progress = (studentId) ->
      co = vm.cumulativeOutcome(studentId)
      return "Not started" unless co?
      co.status

    vm.observedOutcomes = (studentId) ->
      co = vm.cumulativeOutcome(studentId)
      return unless co?
      LearningObjectivesService.observedOutcomesFor(co.id)

    vm.gradeExists = (studentId, assignmentId) ->
      oo = vm.observedOutcomeFor(studentId, assignmentId)
      oo? and oo.outcome_visible

    vm.gradePath = (studentId, assignmentId) ->
      oo = vm.observedOutcomeFor(studentId, assignmentId)
      "/grades/#{oo.grade_id}"

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
