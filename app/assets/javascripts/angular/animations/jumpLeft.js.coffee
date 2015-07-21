angular.module('uiFx').directive 'fadeOutOnClick', ($animate) ->
  (scope, elem) ->
    elem.on 'click', ->
      elem.addClass('fade-out-active').then ->
        console.log 'faded out'
        return
      scope.$apply()
      return
    return
