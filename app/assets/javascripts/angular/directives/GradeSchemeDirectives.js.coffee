@gradecraft.directive 'gradeSchemeRanges', [ 'GradeSchemeElementsService', (GradeSchemeElementsService)->
  restrict: 'A'
  scope: {
    index: '='
    element: '=ngModel'
  }
  controller: ($scope) ->
    this.low_range = (modelValue, viewValue) ->
      if (modelValue < $scope.element.high_range)
        GradeSchemeElementsService.update_scheme($scope.index, modelValue)
        true
      else
        false
    this.high_range = (modelValue, viewValue) ->
      if (modelValue > $scope.element.low_range && modelValue < GradeSchemeElementsService.getTotalPoints())
        true
      else
        false
  templateUrl: 'ng_gradeSchemeRanges.html'
  link: (scope, elm, attrs, ctrl) ->
]

@gradecraft.directive 'lowRange', ()->
  require: ['^gradeSchemeRanges', '^ngModel']
  restrict: 'C'
  link: (scope, elm, attrs, ctrls) ->
    ctrls[1].$validators.range = ctrls[0].low_range

@gradecraft.directive 'highRange', ()->
  require: ['^gradeSchemeRanges', '^ngModel']
  restrict: 'C'
  link: (scope, elm, attrs, ctrls) ->
   ctrls[1].$validators.range = ctrls[0].high_range
    # create an on change binding
