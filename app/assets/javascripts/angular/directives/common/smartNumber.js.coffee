@gradecraft.directive 'smartNumber', ['$filter', ($filter) ->
  return {
    require: 'ngModel',
    link: (scope, element, attrs, modelCtrl)->
      modelCtrl.$parsers.push((inputValue)->
        transformedInput = inputValue.replace(/[^\d-]/g, '')
          .replace(/^0{2,}$/g, '0')
          .replace(/^(-?)0([-\d])/g, '$1$2')

        if transformedInput == '-'
          modelCtrl.$setViewValue('-')
        else
          modelCtrl.$setViewValue($filter('number')(transformedInput))

        modelCtrl.$render()
        return parseInt(transformedInput)
      )

      modelCtrl.$formatters.push((inputValue)->
        return "" if isNaN(inputValue)
        return $filter('number')(inputValue)
      )
  }
]
