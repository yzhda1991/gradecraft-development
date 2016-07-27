# .weighted-earned_points

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
