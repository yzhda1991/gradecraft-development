@gradecraft.directive "learningObjectiveInstructorOverview", ["LearningObjectivesService", "StudentService", "SortableService", "$q",
  (LearningObjectivesService, StudentService, SortableService, $q) ->
    LOInstructorOverviewCtrl = [() ->
      vm = this
      vm.loading = true

      vm.sortable = SortableService
      vm.students = StudentService.students # precondition is that the students have been fetched
      vm.objectives = LearningObjectivesService.objectives

      vm.termFor = (term) -> LearningObjectivesService.termFor(term)
      vm.outcomeForObjective = (studentId, objectiveId) -> LearningObjectivesService.earnedOutcome(studentId, objectiveId, parseInt(@assignmentId))

      vm.sortByObjectiveProgress = (objective) ->
        vm.currentObjective = objective
        (student) -> vm.outcomeForObjective(student.id, vm.currentObjective.id)?.flagged_value_as_i

      services(@courseId, @assignmentId).then(() -> vm.loading = false)
    ]

    services = (courseId, assignmentId) ->
      promises = [
        LearningObjectivesService.getArticles("objectives", { assignment_id: assignmentId }),
        LearningObjectivesService.getOutcomesForAssignment(assignmentId),
      ]
      $q.all(promises)

    {
      scope:
        courseId: "@"
        assignmentId: "@"
      bindToController: true
      controller: LOInstructorOverviewCtrl
      controllerAs: "loInstructorOverviewCtrl"
      templateUrl: "learning_objectives/instructor_overview.html"
    }
]
