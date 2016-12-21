@gradecraft.directive 'gradeRawPoints', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/raw_points.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignments[0]

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)
  }
]
