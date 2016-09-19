@gradecraft.directive 'awardEarnedBadges', ['BadgeService', (BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)

    vm.badgeEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId,badge.id,vm.gradeId)

    vm.awardBadge = (badge)->
      if earnedBadge = vm.badgeEarnedForGrade(badge)
        BadgeService.deeleteEarnedBadge(earnedBadge)
      else
        BadgeService.createEarnedBadge(vm.studentId,badge.id,vm.gradeId)
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

