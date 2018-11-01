# raw_points (display only) for rubric

gradecraft.directive 'gradeRawPointsDisplay',
['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/raw_points.html'
    link: (scope, el, attr)->
      scope.assignment = ()->
        AssignmentService.assignment()
      scope.grade = GradeService.modelGrade
  }
]
