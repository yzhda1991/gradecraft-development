# .weights-coin-widget

# Manages the coin interface for adding and removing weights from Assignment Types
#
# TODO: This directive was moved out of the Predictor Directives but the logic
# has not been refactored. It would probably be good to move the methods and
# model management from this directive into the AssignmentTypeService.
# Let's wait until the default_weight has been removed from GC and then clean
# this up during it's removal.
@gradecraft.directive 'weightsCoinWidget', [ 'AssignmentTypeService', (AssignmentTypeService)->

  return {
    restrict: 'C'
    scope: {
      article: '='
    }
    templateUrl: 'weights/coins.html'
    link: (scope, el, attr)->
      scope.increment = ()->
        @article.student_weight += 1
        AssignmentTypeService.postAssignmentTypeWeight(@article.id,@article.student_weight)
      scope.decrement = ()->
        @article.student_weight -= 1
        AssignmentTypeService.postAssignmentTypeWeight(@article.id,@article.student_weight)
      scope.unusedWeights = ()->
        _.range(AssignmentTypeService.weights.unusedWeights())
      scope.usedWeights = ()->
        _.range(@article.student_weight)
      scope.weightsAvailable = ()->
        if @article.student_weight < 1
          return false if AssignmentTypeService.weights.unusedTypes() < 1
        if AssignmentTypeService.weights.max_weights_per_assignment_type
          @article.student_weight < AssignmentTypeService.weights.max_weights_per_assignment_type && AssignmentTypeService.weights.unusedWeights() > 0
        else
          AssignmentTypeService.weights.unusedWeights() > 0
      scope.hasWeights = ()->
        @article.student_weight > 0
      scope.weightsOpen = ()->
        AssignmentTypeService.weights.open
  }
]

# manages the sum of possible points for an assignment type, and weights it
# with the current weight for that assignment type
@gradecraft.directive 'weightedTotalPoints', [ 'AssignmentTypeService', (AssignmentTypeService)->

  return {
    restrict: 'C'
    scope: {
      article: '='
    }
    templateUrl: 'weights/weighted_total_points.html'
    link: (scope, el, attr)->
      scope.weightedTotalPoints = ()->
        AssignmentTypeService.weightedTotalPoints(@article)
  }
]

# Manages the sum of a student's earned points for an assignment type, and
# weights it with the current weight for that assignment type
@gradecraft.directive 'weightedEarnedPoints', [ 'AssignmentTypeService', (AssignmentTypeService)->

  return {
    restrict: 'C'
    scope: {
      article: '='
    }
    templateUrl: 'weights/weighted_earned_points.html'
    link: (scope, el, attr)->
      scope.weightedEarnedPoints = ()->
        AssignmentTypeService.weightedEarnedPoints(@article)
  }
]
