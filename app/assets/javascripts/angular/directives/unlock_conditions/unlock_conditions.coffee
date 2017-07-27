@gradecraft.directive 'unlockConditions', ['UnlockConditionService', (UnlockConditionService) ->
  unlockConditionsCtrl = [()->
    vmUnlocks = this
    vmUnlocks.loading = true

    vmUnlocks.conditions = UnlockConditionService.unlockConditions

    vmUnlocks.addCondition = ()->
      UnlockConditionService.addCondition()

    UnlockConditionService.getUnlockConditions(@conditionId, @conditionType).then(()->
      vmUnlocks.loading = false
    )
  ]

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

