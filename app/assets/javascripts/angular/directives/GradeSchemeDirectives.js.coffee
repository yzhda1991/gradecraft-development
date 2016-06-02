@gradecraft.directive 'gradeSchemeRanges', [ 'GradeSchemeElementsService', (GradeSchemeElementsService)->
  restrict: 'A'
  scope: {
    index: '='
    element: '=ngModel'
  }
  controller: ($scope) ->
    this.low_points = (modelValue, viewValue) ->
      if (modelValue < $scope.element.high_points || $scope.element.high_points == '')
        GradeSchemeElementsService.update_scheme($scope.index, modelValue)
        true
      else
        false
    this.high_points = (modelValue, viewValue) ->
      if (modelValue > $scope.element.low_points && modelValue < GradeSchemeElementsService.getTotalPoints())
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
    ctrls[1].$validators.range = ctrls[0].low_points

@gradecraft.directive 'highRange', ()->
  require: ['^gradeSchemeRanges', '^ngModel']
  restrict: 'C'
  link: (scope, elm, attrs, ctrls) ->
   ctrls[1].$validators.range = ctrls[0].high_points
    # create an on change binding
