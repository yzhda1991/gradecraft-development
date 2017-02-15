# Iterates over Badges, creating a collapsable section

@gradecraft.directive 'predictorSectionChallenges', [ 'PredictorService', (PredictorService)->

  return {
    templateUrl: 'predictor/challenges.html'
    link: (scope, el, attr)->

      scope.challenges = PredictorService.challenges

      scope.challengesFullPoints = ()->
        PredictorService.challengesFullPoints()

      scope.challengesPredictedPoints = ()->
        PredictorService.challengesPredictedPoints()

  }
]
