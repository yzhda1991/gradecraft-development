@gradecraft = angular.module('gradecraft', ['restangular', 'ui.slider', 'ui.sortable', 'ng-rails-csrf', 'ngResource', 'ngAnimate', 'templates', 'formly', 'formlyFoundation'])

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
    elm.bind('click', ()->
      elm.siblings().toggleClass('collapsed')
    )
    return

#formly config

@gradecraft.constant('appApiCheck', apiCheck({
  output: {prefix: 'gradecraftApp'}
}))

@gradecraft.run((formlyConfig, appApiCheck) ->
  formlyConfig.setType([{
    name: 'gradeScheme',
    templateUrl: 'ng_gradeScheme.html',
    controller: ($scope) ->
      $scope.formOptions = {formState: $scope.formState}
      $scope.addNew = () ->
        debugger
        $scope.model[$scope.options.key] = $scope.model[$scope.options.key] || []
        repeatsection = $scope.model[$scope.options.key]
        lastSection = repeatsection[repeatsection.length - 1]
        newsection = {}
        if (lastSection)
          newsection = angular.copy(lastSection)
        repeatsection.push(newsection)

      $scope.copyFields = (fields) ->
        angular.copy(fields)
  },
  {
    # / %button{:type => 'button', :class => 'remove-element button alert radius', 'ng-click' => 'model[options.key].splice($index, 1)'} Remove
    name: 'button',
    template: '<div><button type="button" ng-click="onClick($event)">{{to.text}}</button></div>',
    defaultOptions: {
      templateOptions: {
        btnType: 'default',
        type: 'button'
      },
      data: {
        skipNgModelAttrsManipulator: true
      }
    },
    controller: ($scope) ->
      $scope.onClick = ($event) ->
        debugger
        $scope.model[$scope.options.key] = $scope.model[$scope.options.key] || []
        $scope.model[$scope.options.key].splice($scope.options.key, 1)
        # if (angular.isString($scope.to.onClick))
        #   return $scope.$eval($scope.to.onClick, {$event: $event})
        # else
        #   return $scope.to.onClick($event)

    apiCheck: {
      templateOptions: appApiCheck.shape({
        onClick: appApiCheck.oneOfType([appApiCheck.string, appApiCheck.func]),
        type: appApiCheck.string.optional,
        btnType: appApiCheck.string.optional,
        text: appApiCheck.string
      })
    },
    apiCheckInstance: appApiCheck
  }])
)
