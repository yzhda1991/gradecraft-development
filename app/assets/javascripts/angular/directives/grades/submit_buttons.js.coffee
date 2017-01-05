# switch for pass/fail grades, alternative to raw_points
@gradecraft.directive 'gradeSubmitButtons', ['GradeService', (GradeService) ->

  return {
    scope: {
      submitPath: "@",
      gradeNextPath: "@"
    }
    templateUrl: 'grades/submit_buttons.html'
    link: (scope, el, attr)->
      scope.grade = GradeService.grade
      scope.submitGrade = (returnURL)->
        GradeService.queueUpdateGrade(true, returnURL)
  }
]
