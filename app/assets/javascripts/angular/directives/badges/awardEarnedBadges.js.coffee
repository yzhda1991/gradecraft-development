@gradecraft.directive 'awardEarnedBadges', ['BadgeService', (BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)
  ]

  {
    bindToController: true,
    controller: AwardedBadgesCtrl,
    controllerAs: 'vm',
    scope: {
      studentId: '@'
      gradeId: '@'
    },
    templateUrl: 'badges/award_earned_badges.html'
  }
]

