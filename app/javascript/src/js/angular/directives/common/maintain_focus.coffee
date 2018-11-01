# Keep focus on the input when the DOM is being updated or re-rendered
# Inspired by: https://stackoverflow.com/a/31929381
gradecraft.directive 'maintainFocus', ['$timeout', ($timeout) ->
  {
    restrict: 'A'
    require: 'ngModel'
    link: ($scope, $element, attrs, ngModel) ->
      ngModel.$parsers.unshift((value) ->
        $timeout(() ->
          $element[0].focus()
        )
        value
      )
  }
]
