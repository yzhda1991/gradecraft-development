@gradecraft.directive 'awardEarnedBadges', ['BadgeService', (BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)

    vm.badgeEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId, badge.id, vm.gradeId)

    vm.badgeAvailable = (badge)->
      badge.available_for_student || vm.badgeEarnedForGrade(badge)

    vm.badgeAwardable = (badge)->
      badge.available_for_student && !vm.badgeEarnedForGrade(badge)

    vm.awardBadge = (badge)->
      return if !vm.badgeAvailable(badge)
      if earnedBadge = vm.badgeEarnedForGrade(badge)
        BadgeService.deleteEarnedBadge(earnedBadge)
        badge.available_for_student = true
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

