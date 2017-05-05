# Selector for earned badges in modal

@gradecraft.directive 'rubricLevelBadgeSelector', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/level_badge_selector.html'
    scope: {
      level: "="
    }
    link: (scope, el, attr)->

      scope.selectBadge = ()->
        # add check for valid ids before submit!
        RubricService.addLevelBadge(scope.level, scope.selectedBadge.id)
  }
]
