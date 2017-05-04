# Display ofbadges earned for level
# Includes modal for awarding earned badges on rubric level

@gradecraft.directive 'rubricLevelBadges', ['RubricService', 'BadgeService', (RubricService, BadgeService) ->

  return {
    templateUrl: 'rubrics/level_badges.html'
    scope: {
      level: "="
    }
    link: (scope, el, attr)->

      scope.badges = BadgeService.badges

      scope.badgesForLevel = ()->
        RubricService.badgesForLevel(@level)

      scope.availableBadges = ()->
        # edit out the badges that can only be earned once, etc.?
        # or all badges already earned?
        BadgeService.badges

      # globally set this level as the one with an open badge edit modal
      scope.editBadges = ()->
        RubricService.editBadgesForLevel(@level)

      # Is this the level with an open modal?
      scope.editingBadges = ()->
        RubricService.editingBadgesForLevel(@level)

      scope.closeBadges = ()->
        RubricService.closeBadgesForLevel()

      scope.selectedBadge = BadgeService.badges[0]

      scope.selectBadge = ()->
        el
        attr
        scope.selectedBadge
        debugger
        console.log("selectBadge")

  }
]
