gradecraft.directive 'badgeEditDetails', ['BadgeService', (BadgeService) ->

  return {
    scope: {
      badge: "="
    }
    templateUrl: 'badges/edit_details.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = BadgeService.termFor


      scope.updateBadge = ()->
        BadgeService.queueUpdateBadge(@badge.id)
  }
]
