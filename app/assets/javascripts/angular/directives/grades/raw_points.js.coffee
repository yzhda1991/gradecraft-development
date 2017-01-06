# standard grade raw_points field

@gradecraft.directive 'gradeRawPoints', ['GradeCraftAPI', 'AssignmentService', 'GradeService', (GradeCraftAPI, AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/raw_points.html'
    link: (scope, el, attr)->

      scope.api = GradeCraftAPI

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)
  }
]
