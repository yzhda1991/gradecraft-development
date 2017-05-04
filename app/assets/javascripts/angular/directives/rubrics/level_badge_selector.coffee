# Selector for earned badges in modal

@gradecraft.directive 'rubricLevelBadgeSelector', [() ->

  return {
    templateUrl: 'rubrics/level_badge_selector.html'
    scope: {
      badges: "="
    }
    link: (scope, el, attr)->

      scope.selectBadge = ()->
        el
        attr
        scope.selectedBadge
        debugger
        console.log("selectBadge")

  }
]
