# Grade status selector for releasing grade to students

@gradecraft.directive 'gradePointsOverview', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/points_overview.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.pointsAllocated = ()->
        return 0 if !scope.grade
        scope.grade.raw_points

      scope.pointsPossible = ()->
        return 0 if !scope.assignment()
        scope.assignment().full_points

      scope.pointsBelowFull = ()->
        scope.pointsPossible() - scope.pointsAllocated()

      #-------------------------------------------------------------------------

      scope.pointsArePresent = ()->
        scope.grade && scope.grade.raw_points != null

      scope.pointsAreLessThanFull = ()->
       scope.pointsArePresent() && (scope.pointsBelowFull() > 0)

      scope.pointsAreSatisfied = ()->
        scope.pointsArePresent() && (scope.pointsBelowFull() == 0)

      scope.pointsAreOver = ()->
        scope.pointsArePresent() && (scope.pointsBelowFull() < 0)

      #-------------------------------------------------------------------------
      scope.adjustmentPoints = ()->
        parseInt(scope.grade.adjustment_points) || 0

      scope.finalPoints = ()->
        return 0 if !scope.pointsArePresent()
        scope.pointsAllocated() - scope.adjustmentPoints()

      #-------------------------------------------------------------------------

      scope.isBelowThreshold = ()->
        return false if !scope.assignment()
        scope.assignment().has_threshold && (scope.finalPoints() < scope.assignment().threshold_points)

      scope.pointsBelowThreshold = ()->
        return 0 if !scope.assignment()
        scope.assignment().threshold_points - scope.finalPoints()

  }
]

