# .collapse-toggler
#
# For collapsing a page section
# see predictor for working example
# toggles .collapse on sibling div

@gradecraft.directive "collapseToggler", ->
  restrict : 'C',
  link: (scope, elm, attrs) ->
    elm.bind('click', (event)->
      if angular.element(event.target).hasClass('collapse-arrow')
        elm.siblings().toggleClass('collapsed')
        elm.toggleClass('collapsed')
    )
    return


# .collapse-all-toggler
#
# opens all, or closes all, regardless of their current state

@gradecraft.directive "collapseAllToggler", ->
  restrict : 'C',
  link: (scope, elm, attrs) ->
    elm.bind('click', ()->
      if elm.hasClass('collapsed')
        angular.element(".collapse-toggler.collapsed .collapse-arrow").click()
      else
        angular.element(".collapse-toggler").not(".collapsed").children(".collapse-arrow").click()
      elm.toggleClass('collapsed')
    )
    return
