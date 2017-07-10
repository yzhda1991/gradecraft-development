@gradecraft.directive 'unlockConditions', ['UnlockConditionService', (UnlockConditionService) ->
  unlockConditionsCtrl = [()->
    @loading = true

    @conditions = UnlockConditionService.unlockConditions

    @addCondition = ()->
      UnlockConditionService.addCondition()

    UnlockConditionService.getUnlockConditions(@conditionId, @conditionType).then(()->
      @loading = false
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

