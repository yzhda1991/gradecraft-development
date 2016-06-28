@gradecraft.directive 'gradeSchemeRanges', [ 'GradeSchemeElementsService', (GradeSchemeElementsService)->
  restrict: 'A'
  scope: {
    index: '='
    element: '=ngModel'
  }
  controller: ($scope) ->
    this.lowest_points = (modelValue) ->
      GradeSchemeElementsService.isLowestPointValue($scope.element, $scope.index, modelValue)

    this.highest_points = (modelValue) ->
      GradeSchemeElementsService.isHighestPointValue($scope.element, $scope.index, modelValue)

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
