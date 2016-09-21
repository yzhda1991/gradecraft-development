@gradecraft.directive 'awardEarnedBadges', ['BadgeService', (BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)

    vm.badgeEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId, badge.id, vm.gradeId)

    vm.badgeAvailable = (badge)->
      badge.can_earn_multiple_times || badge.earned_badge_count < 1

    vm.badgeAwardable = (badge)->
      vm.badgeAvailable(badge) && !vm.badgeEarnedForGrade(badge)

    vm.awardBadge = (badge)->
      return if !vm.badgeAvailable(badge)
      if earnedBadge = vm.badgeEarnedForGrade(badge)
        BadgeService.deleteEarnedBadge(earnedBadge)
      else
        BadgeService.createEarnedBadge(badge.id, vm.studentId, vm.gradeId)
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

