# Manages the coin interface for adding and removing weights from Assignment Types
@gradecraft.directive 'weightsCoinWidget', [ 'AssignmentTypeService', (AssignmentTypeService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'weights/coins.html'
    link: (scope, el, attr)->
      scope.termFor = (term)->
        AssignmentTypeService.termFor(term)

      scope.increment = ()->
        @article.student_weight += 1
        AssignmentTypeService.postAssignmentTypeWeight(@article.id,@article.student_weight)
      scope.decrement = ()->
        @article.student_weight -= 1
        AssignmentTypeService.postAssignmentTypeWeight(@article.id,@article.student_weight)

      scope.unusedWeightsRange = ()->
        AssignmentTypeService.weights.unusedWeightsRange()

      # coin iterator for coins stacked behind the top coin
      scope.coinBackStackRange = ()->
        _.range(@article.student_weight - 1)

      scope.weightsOpen = ()->
        AssignmentTypeService.weights.open

      scope.weightsAvailableForArticle = ()->
        AssignmentTypeService.weightsAvailableForArticle(@article)

      scope.hasWeights = ()->
        @article.student_weight > 0
  }
]
