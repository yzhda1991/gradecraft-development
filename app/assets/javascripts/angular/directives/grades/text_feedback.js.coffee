# overall feedback text for grade
@gradecraft.directive 'gradeTextFeedback', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/text_feedback.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      # TODO: these options are not persisting, see student submission for pattern.
      scope.froalaOptions = {
        inlineMode: false,
        heightMin: 200,
        toolbarButtons: [
          'fullscreen', 'bold', 'italic', 'underline', 'strikeThrough',
          'sep', 'blockStyle', 'emoticons', 'insertTable', 'formatOL', 'formatUL','align',
          'outdent', 'indent', 'insertLink', 'undo', 'redo',
          'clearFormatting', 'selectAll', 'html'
        ]
      }
  }
]
