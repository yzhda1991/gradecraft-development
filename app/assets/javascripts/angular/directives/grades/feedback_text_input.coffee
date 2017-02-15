# input feedback text for grade

@gradecraft.directive 'gradeFeedbackTextInput', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/feedback_text_input.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

  }
]
