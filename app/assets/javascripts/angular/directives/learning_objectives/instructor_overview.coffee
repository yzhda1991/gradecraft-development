@gradecraft.directive 'learningObjectiveInstructorOverview', ['LearningObjectivesService', '$q', (LearningObjectivesService, $q) ->
  LOInstructorOverviewCtrl = [() ->
    vm = this
  ]

  {
    scope:
      assignmentId: '@'
    bindToController: true
    controller: LOInstructorOverviewCtrl
    controllerAs: 'loInstructorOverviewCtrl'
    templateUrl: 'learning_objectives/instructor_overview.html'
  }
]
