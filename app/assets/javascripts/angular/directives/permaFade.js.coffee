Permafade = angular.module('hideAfterFade', [])

Permafade.directive 'hideAfterFade', ['$timeout', ($timeout)->

  hideElement = (elem)->
    elem.addClass("hide-after-fade")

  {
      restrict: 'A'
      require: ''
      scope: {
      }
      link: (scope, elem, attrs, ngModelCtrl) ->

        elem.on "click", ()->
          `$timeout(function() {hideElement(elem)}, 600);`

        scope.$watch (->
          elem.attr 'class'
        ), (newValue, oldValue) ->
          if newValue != oldValue
            allClasses = newValue.split(" ")

            isAvailable = allClasses.indexOf("available") > -1
            isAwarded= allClasses.indexOf("awarded") > -1
            isEarned= allClasses.indexOf("earned") > -1
            isUnearned= allClasses.indexOf("unearned") > -1
            isHidden= allClasses.indexOf("hide-after-fade") > -1


          return


  }
]
