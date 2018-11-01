gradecraft.directive 'badgeEditUnlocks', ['BadgeService', 'UnlockConditionService', (BadgeService, UnlockConditionService) ->

  return {
    scope: {
      badge: "="
    }
    templateUrl: 'badges/edit_unlocks.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = BadgeService.termFor

      scope.updateBadge = ()->
        BadgeService.queueUpdateBadge(@badge.id)
      scope.hasUnlocks = ()->
        UnlockConditionService.unlockConditions.length
  }
]
