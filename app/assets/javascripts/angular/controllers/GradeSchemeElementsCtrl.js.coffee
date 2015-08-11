@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements()

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements
    return
]
