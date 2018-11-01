# displays the last time the grade was updated

gradecraft.directive 'gradeLastUpdated', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/last_updated.html'
    link: (scope, el, attr)->
      scope.grade = GradeService.modelGrade

  }
]
