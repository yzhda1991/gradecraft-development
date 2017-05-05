# Selector for earned badges in modal

@gradecraft.directive 'rubricLevelBadgeSelector', [() ->

  return {
    templateUrl: 'rubrics/level_badge_selector.html'
    scope: {
      badges: "="
      level: "="
    }
    link: (scope, el, attr)->

      scope.selectBadge = ()->
        console.log(scope.selectedBadge.id);
  }
]
