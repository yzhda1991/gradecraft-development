@gradecraft.directive 'unlockConditions', ['$q', 'UnlockConditionService', ($q, UnlockConditionService) ->
  unlockConditionsCtrl = [()->
    vmUnlocks = this

    vmUnlocks.loading = true

    vmUnlocks.conditions = UnlockConditionService.unlockConditions

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

