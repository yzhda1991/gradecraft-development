@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements()

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements

    $scope.updatePreviousElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      previousElement = $scope.grade_scheme_elements[index - 1]

      if previousElement
        previousElement.lowest_points = currentElement.highest_points + 1

    $scope.updateNextElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      nextElement = $scope.grade_scheme_elements[index + 1]

      if nextElement
        newPoints = currentElement.lowest_points - 1
        nextElement.highest_points = newPoints > 0 ? newPoints : 0

    return
]
