# Selector for earned badges in modal

@gradecraft.directive 'rubricLevelBadgeSelector', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/level_badge_selector.html'
    scope: {
      level: "="
    }
    link: (scope, el, attr)->

      scope.selectBadge = ()->
        RubricService.addLevelBadge(scope.level, scope.selectedBadge.id)
  }
]
