# One "Card" in the predictor that displays an Assignment, Challenge, or Badge
# Manages linking article to details section in student side panel

@gradecraft.directive 'predictorArticle',
['PredictorService', 'StudentPanelService', (PredictorService, StudentPanelService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'predictor/article.html'
    link: (scope, el, attr)->
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)

      scope.articleNoPoints = ()->
        PredictorService.articleNoPoints(@article)

      scope.isFocusArticle = ()->
        StudentPanelService.isFocusArticle(@article)

      scope.changeFocusArticle = ()->
        StudentPanelService.changeFocusArticle(@article)
  }
]
