# standard grade raw_points input field

gradecraft.directive 'gradeRawPointsInput', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/raw_points_input.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.modelGrade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)
  }
]
