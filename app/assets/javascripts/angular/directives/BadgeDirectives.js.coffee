@gradecraft.directive 'badgeShow', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'badge/show.html'

  }
]