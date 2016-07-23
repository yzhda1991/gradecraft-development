# .predictor-article-assignment-content

# Fills the Assignment details in the Article "Cards"
@gradecraft.directive 'predictorArticleAssignmentContent', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      article: '='
    }
    templateUrl: 'predictor/article_assignment_content.html'
    link: (scope, el, attr)->
      scope.articleCompleted = ()->
        PredictorService.articleCompleted(@article)
  }
]
