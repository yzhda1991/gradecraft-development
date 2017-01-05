# switch for pass/fail grades, alternative to raw_points
@gradecraft.directive 'gradeLastUpdated', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/last_updated.html'
    link: (scope, el, attr)->
      scope.grade = GradeService.grade

  }
]
