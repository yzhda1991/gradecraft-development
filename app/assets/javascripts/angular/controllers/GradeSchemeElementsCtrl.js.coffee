@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements()

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements

    $scope.updatePreviousElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      previousElement = $scope.grade_scheme_elements[index - 1]

      if currentElement.highest_points > previousElement.lowest_points
        previousElement.lowest_points = currentElement.highest_points + 1

    $scope.updateNextElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      nextElement = $scope.grade_scheme_elements[index + 1]

      if currentElement.lowest_points < nextElement.highest_points
        nextElement.highest_points = currentElement.lowest_points - 1

    return
]
