@gradecraft.directive 'badgeShow', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'ng_badge_show.html'

  }
]
