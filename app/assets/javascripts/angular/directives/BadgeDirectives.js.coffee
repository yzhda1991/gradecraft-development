@gradecraft.directive 'badgeShow', [ 'PredictorService', (PredictorService)->

  return {
    scope: {
      target: '='
    }
    templateUrl: 'badge/show.html'

  }
]
