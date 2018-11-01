# raw_points field when grading with score levels

gradecraft.directive 'gradeScoreLevelsSelect',
['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/score_levels_select.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.modelGrade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

  }
]
