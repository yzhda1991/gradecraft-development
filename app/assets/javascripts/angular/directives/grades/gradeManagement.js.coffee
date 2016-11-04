@gradecraft.directive 'predictor', ['$q', 'GradeService', ($q, GradeService) ->
    PredictorCtrl = [()->
      vm = this

      vm.loading = true
      vm.gradeService = GradeService

      services().then(()->
        vm.loading = false
        StudentPanelService.changeFocusArticle(GradeService.assignments[0])
      )
    ]

    services = ()->
      promises = [GradeService.getGradeSchemeElements(),
        GradeService.getAssignments(),
        GradeService.getAssignmentTypes(),
        GradeService.getBadges(),
        GradeService.getChallenges()]
      return $q.all(promises)

    {
      bindToController: true,
      controller: PredictorCtrl,
      controllerAs: 'vm',
      restrict: 'EA',
      scope: {},
      templateUrl: 'predictor/main.html'
    }
]

