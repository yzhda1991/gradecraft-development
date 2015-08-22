HideAfterFade= angular.module('hideAfterFade', [])

HideAfterFade.directive 'hideAfterFade', ['$timeout', ($timeout)->

  hideElement = (elem)->
    elem.addClass("hide-after-fade")
    elem.removeAttr("disabled")

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
            elem.removeClass("hide-after-fade")

          if isAvailable and isEarned
            elem.addClass("temp-hide")
            elem.removeClass("hide-after-fade")

        elem.on "click", (event)->
          elem.attr("disabled",'')
          `$timeout(function() {hideElement(elem)}, 1000);`

        scope.$watch (->
          elem.attr 'disabled'
        ), (newValue, oldValue) ->
          # alert("disabled") if newValue != oldValue

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
