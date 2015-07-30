Permafade = angular.module('permafade', [])

Permafade.directive 'permafade', ['$timeout', ($timeout)->

  fadeThatShit = (elem)->
    elem.addClass("hidethatshit")

  {
      restrict: 'A'
      require: ''
      scope: {
      }
      link: (scope, elem, attrs, ngModelCtrl) ->

        elem.on "click", ()->
          `$timeout(function() {fadeThatShit(elem)}, 600);`
  }

]
