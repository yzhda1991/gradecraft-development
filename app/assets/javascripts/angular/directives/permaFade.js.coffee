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

        elem.ready ()->
          allClasses = elem.attr("class").split(" ")

          isAvailable = allClasses.indexOf("available") > -1
          isAwarded= allClasses.indexOf("awarded") > -1
          isEarned= allClasses.indexOf("earned") > -1
          isUnearned= allClasses.indexOf("unearned") > -1

          if isAwarded and isUnearned
            elem.addClass("temp-hide")

          if isAvailable and isEarned
            elem.addClass("temp-hide")

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

            if isAwarded and isEarned
              elem.removeClass("hide-after-fade")
              elem.removeClass("temp-hide")

            if isAvailable and isUnearned
              elem.removeClass("hide-after-fade")
              elem.removeClass("temp-hide")

          return


  }
]
