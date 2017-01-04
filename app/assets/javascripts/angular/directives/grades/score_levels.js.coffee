# raw_points field when grading with score levels
@gradecraft.directive 'gradeScoreLevels', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/score_levels.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.toggleCustomValue = ()->
        GradeService.toggleCustomValue()

      scope.textForToggle = ()->
        if GradeService.grade.is_custom_value then "Change to score level selector" else "Change to custom value"
  }
]
