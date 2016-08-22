# .model-int-converter

# Converts model Integer to presentation String
# used to handle smart-number field for predicted_points in slider
@gradecraft.directive 'modelIntConverter', [()->
  return {
    restrict: 'C'
    require: 'ngModel'
    link: (scope, element, attrs, ngModelController)->
      ngModelController.$parsers.push((data)->
        #convert data to integer on model
        return parseInt(data)
      )

      ngModelController.$formatters.push((data)->
        #convert data to string for view
        return "" if isNaN(data)
        return data.toString()
      )
  }
]
