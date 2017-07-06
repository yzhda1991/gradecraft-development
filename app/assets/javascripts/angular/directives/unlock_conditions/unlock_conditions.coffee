@gradecraft.directive 'unlockConditions', ['$q', 'UnlockConditionService', ($q, UnlockConditionService) ->
  unlockConditionsCtrl = [()->
    vmUnlocks = this

    vmUnlocks.loading = true

    vmUnlocks.conditions = UnlockConditionService.unlockConditions
    vmUnlocks.termFor = (item)->
      UnlockConditionService.termFor(item)

    vmUnlocks.condition_types = ["Assignment Type", "Assignment", "Badge", "Earned Point Value"]

    vmUnlocks.assignments = UnlockConditionService.assignments
    vmUnlocks.assignmentStates = (assignmentId)->
      assignment = _.find(UnlockConditionService.assignments, {id: assignmentId})
      if assignment && assignment.pass_fail
        ["Submitted", "Feedback Read", "Passed"]
      else
        ["Submitted", "Feedback Read", "Grade Earned"]

    vmUnlocks.inspector = (condition)->
      debugger

    services(@conditionId, @conditionType).then(()->
      vmUnlocks.loading = false
    )
  ]

  services = (conditionId, conditionType)->
    promises = [UnlockConditionService.getUnlockConditions(conditionId, conditionType)]
    return $q.all(promises)

  {
    bindToController: true,
    controller: unlockConditionsCtrl,
    controllerAs: 'vmUnlocks',
    restrict: 'EA',
    scope: {
      conditionId: "=",
      conditionType: "@"
      },
    templateUrl: 'unlock_conditions/main.html'
  }
]

