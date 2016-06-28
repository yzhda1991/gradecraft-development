@gradecraft.directive 'gradeSchemeRanges', [ 'GradeSchemeElementsService', (GradeSchemeElementsService)->
  restrict: 'A'
  scope: {
    index: '='
    element: '=ngModel'
  }
  controller: ($scope) ->
    this.lowest_points = (modelValue) ->
      # update the previous grade scheme element if our lowest_points value has
      # dropped below its highest_points value
      #
      GradeSchemeElementsService
        .updatePreviousElementIfLower($scope.element, $scope.index, modelValue)

    this.highest_points = (modelValue) ->
      # update the next grade scheme element if our highest_points value has
      # become greater than its lowest_points value
      #
      GradeSchemeElementsService
        .updateNextElementIfHigher($scope.element, $scope.index, modelValue)

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
