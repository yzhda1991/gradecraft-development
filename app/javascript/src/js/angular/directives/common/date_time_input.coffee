gradecraft.directive 'gcDateTimeInput', [ "$timeout", "$filter", ($timeout, $filter) ->

  return {
    restrict: 'A',
    require: 'ngModel',
    transclude: true,
    link : (scope, element, attrs, modelCtrl)->
      # timeout is necessary for jQuery UI to work on the element
      $timeout( ()->
        element.datetimepicker({
          controlType: 'select',
          oneLine: true,
          dateFormat: 'MM d, yy -',
          timeFormat: 'h:mmtt'
          onSelect: (date)=>
            modelCtrl.$setViewValue(date);
            scope.date = date
            scope.$apply()
        })
      )

      # Parse string back to Date on model.
      # This is necessary to make sure that validators are
      # evaluating Dates, not strings
      modelCtrl.$parsers.push((inputValue)->
        # requires datejs (http://www.datejs.com/) to parse date and time
        return Date.parse(inputValue.replace("-", ""))
      )

      # Format date as string matching datetimepicker's
      # dateFormat and Timeformat.
      modelCtrl.$formatters.push((inputValue)->
        return $filter('date')(inputValue, 'MMMM d, y - h:mma')
      )
  }
]
