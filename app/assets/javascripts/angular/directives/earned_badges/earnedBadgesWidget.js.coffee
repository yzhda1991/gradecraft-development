@gradecraft.directive 'awardedBadgesWidget', ['BadgeService', (BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService

    BadgeService.getBadges()
  ]

  {
    bindToController: true,
    controller: AwardedBadgesCtrl,
    controllerAs: 'vm',
    restrict: 'EA',
    scope: {},
    templateUrl: 'earned_badges/main.html'
  }
]

