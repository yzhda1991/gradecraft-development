# Hovering synopsis of the grade calculation
# Not used for group or pass/fail assignments

@gradecraft.directive 'gradePointsOverview', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/points_overview.html'
    scope: {
      gradeType: "@"
    }
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.modelGrade

      scope.firstGrade = ()->
        GradeService.grades[0]

      scope.finalPoints = ()->
        return 0 if !GradeService.grades.length
        GradeService.grades[0].final_points

      scope.pointsBelowFull = ()->
        return 0 if !scope.assignment() || !scope.grade
        return 0 if !scope.assignment().full_points || !scope.pointsArePresent()
        scope.assignment().full_points - scope.grade.raw_points

      scope.pointsArePresent = ()->
        scope.grade && scope.grade.raw_points != null

      scope.pointsAreLessThanFull = ()->
       scope.pointsArePresent() && (scope.pointsBelowFull() > 0)

      scope.pointsAreSatisfied = ()->
        scope.pointsArePresent() && (scope.pointsBelowFull() == 0)

      scope.pointsAreOver = ()->
        scope.pointsArePresent() && (scope.pointsBelowFull() < 0)

      scope.adjustmentPoints = ()->
        parseInt(GradeService.grades[0].adjustment_points) || 0

      scope.isBelowThreshold = ()->
        return false if !(scope.assignment() && scope.grade)
        scope.assignment().has_threshold && (scope.finalPoints() < scope.assignment().threshold_points)

      scope.pointsBelowThreshold = ()->
        return 0 if !(scope.assignment() && scope.grade)
        scope.assignment().threshold_points - scope.grade.raw_points + scope.adjustmentPoints()

  }
]
