# Entry point for editing an badge
@gradecraft.directive 'badgeEdit', ['BadgeService', (BadgeService) ->
  BadgeEditCtrl = [()->
    vmBadgeEdit = this
    vmBadgeEdit.loading = true

    vmBadgeEdit.badges = BadgeService.badges

    BadgeService.getBadge(vmBadgeEdit.badgeId).then(()->
      vmBadgeEdit.loading = false
    )
  ]

  {
    bindToController: true,
    controller: BadgeEditCtrl,
    controllerAs: 'vmBadgeEdit',
    templateUrl: 'badges/badge_edit.html',
    scope: {
      badgeId: "="
    }
  }
]
