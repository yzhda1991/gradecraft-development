# Fills the Assignment details in the Article "Cards"
gradecraft.directive 'predictorArticleAssignmentContent', [ 'PredictorService', (PredictorService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'predictor/article_assignment_content.html'
    link: (scope, el, attr)->
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)

      scope.termFor = (term)->
        PredictorService.termFor(term)
  }
]
