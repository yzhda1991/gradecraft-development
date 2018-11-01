gradecraft.directive 'gcNumberInput', ['$filter', ($filter) ->
  return {
    scope: {
      allowNegatives: "="
    }
    require: 'ngModel',
    link: (scope, element, attrs, modelCtrl)->
      modelCtrl.$parsers.push((inputValue)->
        inputValue = inputValue.replace(/-/g, '') unless scope.allowNegatives
        inputValue = inputValue.replace(/[^\d-]/g, '')
          .replace(/^(-)0/g, '$1')

        if inputValue == '-' || inputValue == '0-'
          modelCtrl.$setViewValue('-')
          inputValue = 0
        else
          modelCtrl.$setViewValue($filter('number')(inputValue))

        modelCtrl.$render()
        return parseInt(inputValue)
      )

      modelCtrl.$formatters.push((inputValue)->
        return "" if isNaN(inputValue)
        return $filter('number')(inputValue)
      )
  }
]
