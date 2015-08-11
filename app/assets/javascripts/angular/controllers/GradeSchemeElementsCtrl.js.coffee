@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      console.log($scope.grade_scheme_elements)
    )

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements
    return
]
