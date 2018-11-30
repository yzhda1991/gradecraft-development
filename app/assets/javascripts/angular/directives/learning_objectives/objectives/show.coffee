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

      vm.sortByAssessment = (assignment) -> vm.earnedOutcome(vm.studentId, @objectiveId, assignment.id)?.flagged_value
      vm.sortBySubmittedAssignments = (student) -> vm.submissionsForStudent(student.id)?.length
      vm.sortByPercentComplete = (student) -> vm.percentComplete(student.id)
      vm.sortBySubmittedAt = (assignment) -> vm.submittedAt(assignment.id)
      vm.sortByResubmitted = (assignment) -> vm.resubmitted(assignment.id)
      vm.sortByGradedAssignments = (student) -> vm.observedOutcomes(student.id)?.length

      vm.submissionsForStudent = (student_id) -> SubmissionService.forStudent(student_id)
      vm.percentComplete = (studentId) -> vm.cumulativeOutcome(studentId)?.percent_complete
      vm.numericProgress = (studentId) -> vm.cumulativeOutcome(studentId)?.numeric_progress

      vm.earnedOutcome = (assignmentId) ->
        LearningObjectivesService.earnedOutcome(parseInt(@studentId), parseInt(@objectiveId), assignmentId)

      vm.cumulativeOutcome = (studentId) ->
        _studentId = if angular.isDefined(studentId) then studentId else @studentId
        _.find(LearningObjectivesService.cumulativeOutcomes, { user_id: parseInt(_studentId) })

      vm.progress = (studentId) ->
        co = vm.cumulativeOutcome(studentId)
        return "Not started" unless co?
        co.status

      vm.observedOutcomes = (studentId) ->
        _studentId = if angular.isDefined(studentId) then studentId else @studentId
        LearningObjectivesService.observedOutcomesForStudent(parseInt(@objectiveId), _studentId)

      vm.showPath = (studentId) ->
        "/learning_objectives/objectives/#{@objectiveId}?student_id=#{studentId}"

      vm.submittedAt = (assignmentId) ->
        SubmissionService.forStudentAndAssignment(parseInt(@studentId), assignmentId)?.submitted_at

      vm.resubmitted = (assignmentId) ->
        SubmissionService.forStudentAndAssignment(parseInt(@studentId), assignmentId)?.resubmitted

      services(@objectiveId, @studentId).then(() ->
        SubmissionService.getSubmissions(_.pluck(vm.linkedAssignments, "id")).then(() -> vm.loading = false)
      )
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
