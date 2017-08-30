@gradecraft.directive 'predictor', ['$q', 'PredictorService', 'StudentPanelService',
  ($q, PredictorService, StudentPanelService) ->
    PredictorCtrl = [()->
      vm = this

      vm.loading = true
      vm.predictorService = PredictorService

      services().then(()->
        vm.loading = false
        StudentPanelService.changeFocusArticle(PredictorService.assignments[0])
      )
    ]

    services = ()->
      promises = [PredictorService.getGradeSchemeElements(),
        PredictorService.getAssignments(),
        PredictorService.getAssignmentTypes(),
        PredictorService.getBadges(),
        PredictorService.getChallenges()]
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
