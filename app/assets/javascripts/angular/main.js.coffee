@gradecraft = angular.module('gradecraft', ['restangular', 'ui.slider', 'ui.sortable', 'ng-rails-csrf', 'ngResource', 'ngAnimate', 'templates'])

INTEGER_REGEXP = /^\-?\d+$/
@gradecraft.directive "integer", ->
  require: "ngModel"
  link: (scope, elm, attrs, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      if INTEGER_REGEXP.test(viewValue)
        # it is valid
        ctrl.$setValidity "integer", true
        viewValue
      else
        # it is invalid, return undefined (no model update)
        ctrl.$setValidity "integer", false
        'undefined'
    return

@gradecraft.directive "collapseToggler", ->
  restrict : 'C',
  link: (scope, elm, attrs) ->
    elm.bind('click', (event)->
      if angular.element(event.target).hasClass('collapse-arrow')
        elm.siblings().toggleClass('collapsed')
        elm.toggleClass('collapsed')
    )
    return

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

@gradecraft.filter 'list', ['$sce', ($sce)->
  (input)->
    if typeof(input) == "string"
      return $sce.trustAsHtml(input)
    else if Array.isArray(input)
      return $sce.trustAsHtml("<ul><li>" + input.join('</li><li>') + "</li></ul>")
]
