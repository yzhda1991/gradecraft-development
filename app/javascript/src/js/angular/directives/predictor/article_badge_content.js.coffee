# Fills the Badge details in the "Cards"
gradecraft.directive 'predictorArticleBadgeContent', [ 'PredictorService', (PredictorService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'predictor/article_badge_content.html'
    link: (scope, el, attr)->
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)

      scope.pointsDisplay = ()->
          return "earned" if @article.total_earned_points == 0
          return @article.total_earned_points
  }
]
