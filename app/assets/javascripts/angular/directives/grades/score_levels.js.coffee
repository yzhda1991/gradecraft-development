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

      scope.switchText = ()->
        if GradeService.grade.is_custom_value then "Enter as score level" else "Enter as custom value"
  }
]
