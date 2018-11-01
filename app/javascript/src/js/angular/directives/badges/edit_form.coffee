# Main Edit form with tabbed sections
gradecraft.directive 'badgeEditForm', ['BadgeService', (BadgeService) ->

  return {
    scope: {
      badge: "="
    }
    templateUrl: 'badges/edit_form.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.termFor = BadgeService.termFor

      scope.updateBadge = ()->
        BadgeService.queueUpdateBadge(@badge.id)

      scope.submitBadge = ()->
        BadgeService.submitBadge(@badge.id)

      scope.tabInFocus = "basics"
      scope.focusTab = (focus)->
        scope.tabInFocus = focus
      scope.isFocusTab = (focus)->
        return true if focus == scope.tabInFocus
        return false
  }
]


