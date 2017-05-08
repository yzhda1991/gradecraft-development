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

      # globally set this level as the one with an open badge edit modal
      scope.editBadges = ()->
        RubricService.editBadgesForLevel(@level)

      # Is this the level with an open modal?
      scope.editingBadges = ()->
        RubricService.editingBadgesForLevel(@level)

      scope.closeBadges = ()->
        RubricService.closeBadgesForLevel()

      scope.deleteLevelBadge = (badgeId)->
        RubricService.deleteLevelBadge(scope.level, badgeId)
  }
]
