# rubric controlled raw_points

@gradecraft.directive 'gradeRubric', ['GradeCraftAPI', 'AssignmentService', 'GradeService', 'RubricService', (GradeCraftAPI, AssignmentService, GradeService, RubricService) ->

  return {
    templateUrl: 'grades/rubric.html'
    link: (scope, el, attr)->

      scope.api = GradeCraftAPI

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)
  }
]
