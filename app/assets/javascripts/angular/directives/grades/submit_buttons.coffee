# buttons to submit grade and redirect on success

@gradecraft.directive 'gradeSubmitButtons', ['GradeService', (GradeService) ->

  return {
    scope: {
      submitPath: "@",
      gradeNextPath: "@"
    }
    templateUrl: 'grades/submit_buttons.html'
    link: (scope, el, attr)->
      scope.grade = GradeService.modelGrade
      scope.submitGrade = (returnURL)->
        GradeService.submitGrade(returnURL)
  }
]
