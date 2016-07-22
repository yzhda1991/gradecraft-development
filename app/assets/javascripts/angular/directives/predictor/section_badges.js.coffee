# .predictor-section-badges

# Iterates over Badges, creating a collapsable section

@gradecraft.directive 'predictorSectionBadges', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    templateUrl: 'predictor/badges.html'
    link: (scope, el, attr)->

      scope.badges = PredictorService.badges

      scope.termFor = (article)->
        PredictorService.termFor(article)

      scope.badgesPredictedPoints = ()->
        PredictorService.badgesPredictedPoints()
  }
]
