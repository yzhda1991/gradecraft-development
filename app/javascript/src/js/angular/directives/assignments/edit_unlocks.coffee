gradecraft.directive 'assignmentEditUnlocks', ['AssignmentTypeService', 'AssignmentService', 'UnlockConditionService', (AssignmentTypeService, AssignmentService, UnlockConditionService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/edit_unlocks.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor

      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)

      scope.hasUnlocks = ()->
        UnlockConditionService.unlockConditions.length
  }
]
