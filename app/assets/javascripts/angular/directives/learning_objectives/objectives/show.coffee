@gradecraft.directive "learningObjectivesShow", ["LearningObjectivesService", "CourseService", "SubmissionService", "SortableService", "orderByFilter", "$q",
  (LearningObjectivesService, CourseService, SubmissionService, SortableService, orderBy, $q) ->
    LearningObjectivesShowCtrl = [() ->
      vm = this
      vm.loading = true
      vm.sortable = SortableService
      vm.students = CourseService.students
      vm.objective = LearningObjectivesService.objective
      vm.linkedAssignments = LearningObjectivesService.linkedAssignments

      vm.termFor = (term) -> LearningObjectivesService.termFor(term)

      vm.sortByAssessment = (assignment) -> vm.earnedOutcome(vm.studentId, assignment.id).flagged_value
      vm.sortBySubmittedAssignments = (student) -> vm.submissionsForStudent(student.id).length
      vm.sortByPercentComplete = (student) -> vm.percent_complete(student.id)
      vm.sortByGradedAssignments = (student) ->
        outcomes = vm.observedOutcomes(student.id) || []
        outcomes.length

      vm.submissionsForStudent = (student_id) -> SubmissionService.forStudent(student_id)

      vm.earnedOutcome = (studentId, assignmentId) ->
        LearningObjectivesService.earnedOutcome(parseInt(studentId), assignmentId)

      vm.gradeExists = (assignmentId) -> observedOutcomeFor(parseInt(@studentId), assignmentId)?

      vm.cumulativeOutcome = (studentId) ->
        _studentId = if angular.isDefined(studentId) then studentId else @studentId
        _.find(LearningObjectivesService.cumulativeOutcomes, { user_id: parseInt(_studentId) })

      vm.progress = (studentId) ->
        co = vm.cumulativeOutcome(studentId)
        return "Not started" unless co?
        co.status

      vm.percent_complete = (studentId) ->
        co = vm.cumulativeOutcome(studentId)
        return "Not started" unless co?
        co.percent_complete

      vm.numeric_progress = (studentId) ->
        co = vm.cumulativeOutcome(studentId)
        return "Not started" unless co?
        co.numeric_progress

      # TODO: needed?
      vm.observedOutcomes = (studentId) ->
        _studentId = if angular.isDefined(studentId) then studentId else @studentId
        LearningObjectivesService.observedOutcomesForStudent(_studentId)

      vm.gradePath = (studentId, assignmentId) ->
        oo = observedOutcomeFor(parseInt(studentId), assignmentId)
        "/grades/#{oo.grade_id}"

      vm.showPath = (studentId) ->
        "/learning_objectives/objectives/#{@objectiveId}?student_id=#{studentId}"

      services(@objectiveId, @studentId).then(() ->
        SubmissionService.getSubmissions(_.pluck(vm.linkedAssignments, "id"))
        vm.loading = false
      )
    ]

    observedOutcomeFor = (studentId, assignmentId) ->
      oo = LearningObjectivesService.observedOutcomesForStudent(studentId)
      return unless oo?
      _.find(oo, { assignment_id: assignmentId })

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
