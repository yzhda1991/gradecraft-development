# .weighted-total-points

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
