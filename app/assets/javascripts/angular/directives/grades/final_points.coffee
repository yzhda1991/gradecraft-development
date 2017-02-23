# display calculated final_points

@gradecraft.directive 'gradeFinalPoints', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/final_points.html'
    link: (scope, el, attr)->
      scope.grades = GradeService.grades
  }
]
