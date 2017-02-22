@gradecraft.directive 'gradeEarnedBadgesSelect', ['GradeService', 'BadgeService', (GradeService, BadgeService) ->
  AwardedBadgesCtrl = [()->
    vm = this
    vm.BadgeService = BadgeService
    BadgeService.getBadges(vm.studentId)

    vm.badgeEarnedForGrade = (badge)->
      BadgeService.studentEarnedBadgeForGrade(vm.studentId, badge.id, GradeService.grade.id)

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
        BadgeService.createEarnedBadge(badge.id, vm.studentId, GradeService.grade.id)
  ]

  {
    bindToController: true,
    controller: AwardedBadgesCtrl,
    controllerAs: 'vm',
    scope: {
      studentId: '@'
    },
    templateUrl: 'grades/earned_badges_select.html'
  }
]

