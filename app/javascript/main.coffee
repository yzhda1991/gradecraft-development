window.gradecraft = angular.module('gradecraft', [
  'ngAnimate',
  'ngDragDrop',
  'ngDraggable',
  'restangular',
  'ui.sortable',
  'puElasticInput',
  'ui.router',
  'ng-rails-csrf',
  'ngResource',
  'froala',
  'templates',
  'helpers',
  'ngAria',
  'tandibar/ng-rollbar'
])

angular.module("templates", [])

gradecraft.config ($stateProvider, $urlRouterProvider, $locationProvider) ->

gradecraft.config(['$compileProvider', ($compileProvider)->
  $compileProvider.debugInfoEnabled(false)
])

gradecraft.config(['$ariaProvider', ($ariaProvider)->
  $ariaProvider.config({
    ariaRequired: false
  })
]);

gradecraft.config(['RollbarProvider', (RollbarProvider) ->
  _config = angular.element("rollbar-js")[0]
  _token = if _config? then _config.getAttribute("data-client-token") else "POST_CLIENT_ITEM_ACCESS_TOKEN"
  _environment = if _config? then _config.getAttribute("data-environment") else "unknown"
  _person = if _config? then angular.fromJson(_config.getAttribute("data-person"))
  Rollbar.error "Failed to fetch Rollbar configuration during config phase" if not _config?

  RollbarProvider.init({
    accessToken: _token
    captureUncaught: true
    payload:
      environment: _environment
      person: _person
  })
])

gradecraft.directive "modalDialog", ->
  restrict: "E"
  scope:
    show: "="

  replace: true # Replace with the template below
  transclude: true # we want to insert custom content inside the directive
  link: (scope, element, attrs) ->
    scope.dialogStyle = {}
    scope.dialogStyle.width = attrs.width  if attrs.width
    scope.dialogStyle.height = attrs.height  if attrs.height
    scope.hideModal = ->
      scope.show = false
      return

    return

  template: "..." # See below

INTEGER_REGEXP = /^\-?\d+$/
gradecraft.directive "integer", ->
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

FLOAT_REGEXP = /^\-?\d+((\.|\,)\d+)?$/
gradecraft.directive "smartFloat", ->
  require: "ngModel"
  link: (scope, elm, attrs, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      if FLOAT_REGEXP.test(viewValue)
        ctrl.$setValidity "float", true
        parseFloat viewValue.replace(",", ".")
      else
        ctrl.$setValidity "float", false
        `undefined`

    return

gradecraft.directive "ngMax", ->
  require: "ngModel"
  link: (scope, elm, attr, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      value = viewValue
      #alert("value:" + value)
      max = scope.$eval(attr.ngMax)
      #alert("max:" + max)
      if value and value != "" and value > max
        ctrl.$setValidity "ngMax", false
        'undefined'
      else
        ctrl.$setValidity "ngMax", true
        value

    return

gradecraft.directive "ngOnscreen", ->
  require: "ngModel"
  link: (scope, elm, attr, ctrl) ->
    ctrl.$parsers.unshift (viewValue) ->
      value = viewValue
      max = scope.$eval(attr.ngMax)
      if value and value != "" and value > max
        ctrl.$setValidity "ngMax", false
        'undefined'
      else
        ctrl.$setValidity "ngMax", true
        value

    return


gradecraft.filter 'list', ['$sce', ($sce)->
  (input)->
    if typeof(input) == "string"
      return $sce.trustAsHtml(input)
    else if Array.isArray(input)
      return $sce.trustAsHtml("<ul><li>" + input.join('</li><li>') + "</li></ul>")
]

gradecraft.filter 'html', ['$sce', ($sce)->
  (val) ->
    return $sce.trustAsHtml val
]
