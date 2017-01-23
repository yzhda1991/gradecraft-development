# grade adjustment_points input field

@gradecraft.directive 'gradeAdjustmentPoints', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/adjustment_points.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.froalaOptions = {
        heightMin: 50,
      }
  }
]
