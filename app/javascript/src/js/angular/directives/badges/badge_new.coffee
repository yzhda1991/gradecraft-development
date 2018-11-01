# Entry point for a new badge. Once the badge is
# created, the edit form is disiplayed
gradecraft.directive 'badgeNew', ['BadgeService', (BadgeService) ->
  BadgeNewCtrl = [()->
    vmBadgeNew = this
    vmBadgeNew.badgeCreated = false
    vmBadgeNew.badges = BadgeService.badges
    vmBadgeNew.newBadge = {
      name: null
    }

    vmBadgeNew.createBadge = ()->
      BadgeService.createBadge(vmBadgeNew.newBadge).then(()->
        if BadgeService.badges.length
          vmBadgeNew.badgeCreated = true
      )
  ]

  {
    bindToController: true,
    controller: BadgeNewCtrl,
    controllerAs: 'vmBadgeNew',
    templateUrl: 'badges/badge_new.html',
  }
]
