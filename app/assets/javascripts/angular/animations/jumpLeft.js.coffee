angular.module('uiFx').directive 'jumpLeftOnClick', ($animate) ->
  (scope, elem) ->
    elem.on 'mouseOver', ->
      $animate.animate(elem, 'jump-left').then ->
        console.log 'jumped left'
        return
      scope.$apply()
      return
    return
