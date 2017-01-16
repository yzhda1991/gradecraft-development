@gradecraft.directive 'smartNumber', [() ->
  return {
    require: 'ngModel',
    link: (scope, element, attrs, modelCtrl)->
      modelCtrl.$parsers.push((inputValue)->
        transformedInput = inputValue.replace(/\D/g, '')
          .replace(/^0{2,}$/g, '0')
          .replace(/^0(\d+)/g, '$1')

        if (transformedInput!=inputValue)
          modelCtrl.$setViewValue(transformedInput)
          modelCtrl.$render()
        return transformedInput
      )
  }
]
