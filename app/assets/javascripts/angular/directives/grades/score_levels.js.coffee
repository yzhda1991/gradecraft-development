# raw_points field when grading with score levels

@gradecraft.directive 'gradeScoreLevels', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/score_levels.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

  }
]
