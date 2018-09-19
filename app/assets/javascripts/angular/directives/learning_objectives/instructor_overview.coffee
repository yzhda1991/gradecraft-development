@gradecraft.directive "learningObjectiveInstructorOverview", ["LearningObjectivesService", "StudentService", "$q",
  (LearningObjectivesService, StudentService, $q) ->
    LOInstructorOverviewCtrl = [() ->
      vm = this
      vm.loading = true
      vm.students = StudentService.students # precondition is that the students have been fetched
      vm.objectives = LearningObjectivesService.objectives

      vm.termFor = (term) -> LearningObjectivesService.termFor(term)
      vm.outcomeForObjective = (studentId, objectiveId) -> LearningObjectivesService.earnedOutcome(studentId, objectiveId, parseInt(@assignmentId))

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
