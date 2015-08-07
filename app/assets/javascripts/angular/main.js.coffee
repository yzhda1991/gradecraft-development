@gradecraft = angular.module('gradecraft', ['restangular', 'ui.slider', 'ui.sortable', 'ng-rails-csrf', 'ngResource', 'ngMessages', 'ngAnimate', 'templates', 'formly', 'formlyFoundation'])

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
@gradecraft.constant('gcApiCheck', apiCheck());

@gradecraft.run((formlyConfig, formlyValidationMessages, gcApiCheck) ->
  formlyConfig.extras.ngModelAttrsManipulatorPreferBound = true;
  formlyValidationMessages.addStringMessage('maxlength', 'Input Too Long');
  formlyValidationMessages.messages.pattern = (viewValue, modelValue, scope) ->
    viewValue + ' is invalid'
  formlyValidationMessages.addTemplateOptionValueMessage('minlength', 'minlength', '', 'is the minimum length', 'Too short')

  formlyConfig.setWrapper(
    {
      name: 'inputInvalid',
      types: ['input', 'validatedInput'],
      templateUrl: 'ng_inputWrapper.html'
    }
    # ,
    # {
      # template: [
      #   '<div class="formly-template-wrapper form-group"',
      #   'ng-class="{\'has-error\': options.validation.errorExistsAndShouldBeVisible}">',
      #   '<label for="{{::id}}">{{options.templateOptions.label}} {{options.templateOptions.required ? \'*\' : \'\'}}</label>',
      #   '<formly-transclude></formly-transclude>',
      #   '<div class="validation"',
      #   'ng-if="options.validation.errorExistsAndShouldBeVisible"',
      #   'ng-messages="options.formControl.$error">',
      #   '<div ng-messages-include="validation.html"></div>',
      #   '<div ng-message="{{::name}}" ng-repeat="(name, message) in ::options.validation.messages">',
      #   '{{message(options.formControl.$viewValue, options.formControl.$modelValue, this)}}',
      #   '</div>',
      #   '</div>',
      #   '</div>'
      # ].join(' ')
    # },
    )

  formlyConfig.setType([
    {
      name: 'gradeScheme',
      templateUrl: 'ng_gradeScheme.html',
      controller: ($scope) ->
        $scope.formOptions = {formState: $scope.formState}
        $scope.addNew = () ->
          $scope.model[$scope.options.key] = $scope.model[$scope.options.key] || []
          repeatsection = $scope.model[$scope.options.key]
          lastSection = repeatsection[repeatsection.length - 1]
          newsection = {}
          # if (lastSection)
          #   newsection = angular.copy(lastSection)
          repeatsection.push(newsection)

        $scope.remove = (sections, $index) ->
          sections.splice($index, 1)

        $scope.copyFields = (fields) ->
          angular.copy(fields)
    },
    {
      name: 'validatedInput',
      extends: 'input',
      apiCheck: {
        templateOptions: gcApiCheck.shape({
          foo: gcApiCheck.string.optional
        })
      }
    }
  ])
)
