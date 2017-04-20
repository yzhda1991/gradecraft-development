@gradecraft.directive 'gcDateTime', [ "$timeout", ($timeout) ->

  linker = (scope, element, attrs, ctrl)->
    $timeout( ()->
      element.datetimepicker({
        controlType: 'select',
        oneLine: true,
        dateFormat: 'MM d, yy -',
        timeFormat: 'h:mmtt'
        onSelect: (date)=>
          ctrl.$setViewValue(date);
          scope.date = date
          scope.$apply()
      })
    )


  return {
    restrict: 'A',
    require: 'ngModel',
    transclude: true,
    link : linker
  }
]
