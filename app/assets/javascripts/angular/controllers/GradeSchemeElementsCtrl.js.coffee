@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements()

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements

    $scope.validateElements = (index)->
      for element, i in $scope.grade_scheme_elements
        $scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('conflict', true)
        for otherElement, j in $scope.grade_scheme_elements
          continue if i == j

          pointRange = [(element.lowest_points - 1)..(element.lowest_points + 1)]
          if otherElement.lowest_points in pointRange
            $scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('conflict', false)
            $scope.gradeSchemeForm["lowest_points_#{j}"].$setValidity('conflict', false)
    return
]
