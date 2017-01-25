# grade adjustment_points input field

@gradecraft.directive 'gradeAdjustmentPointsInput', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/adjustment_points_input.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.froalaOptions = {
        heightMin: 50,
      }
  }
]
