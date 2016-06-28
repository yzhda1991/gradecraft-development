@gradecraft.directive 'gradeSchemeRanges', [ 'GradeSchemeElementsService', (GradeSchemeElementsService)->
  restrict: 'A'
  scope: {
    index: '='
    element: '=ngModel'
  }
  controller: ($scope) ->
    this.lowest_points = (modelValue) ->
      if (modelValue < $scope.element.highest_points || $scope.element.highest_points == '')
        GradeSchemeElementsService.update_high_range($scope.index, modelValue)
        true
      else
        false
    this.highest_points = (modelValue) ->
      if (modelValue > $scope.element.lowest_points || $scope.element.lowest_points == '' )
        GradeSchemeElementsService.update_low_range($scope.index, modelValue)
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
    ctrls[1].$validators.range = ctrls[0].lowest_points

@gradecraft.directive 'highRange', ()->
  require: ['^gradeSchemeRanges', '^ngModel']
  restrict: 'C'
  link: (scope, elm, attrs, ctrls) ->
    ctrls[1].$validators.range = ctrls[0].highest_points
