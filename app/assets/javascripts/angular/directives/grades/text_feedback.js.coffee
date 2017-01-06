# input feedback text for grade

@gradecraft.directive 'gradeTextFeedback', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/text_feedback.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

  }
]
