@gradecraft.directive 'assignmentScoreLevels', ['AssignmentTypeService', 'AssignmentService', (AssignmentTypeService, AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/score_levels.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)

      scope.updateScoreLevel = (scoreLevel)->
        AssignmentService.queueUpdateScoreLevel(@assignment.id, scoreLevel)
  }
]
