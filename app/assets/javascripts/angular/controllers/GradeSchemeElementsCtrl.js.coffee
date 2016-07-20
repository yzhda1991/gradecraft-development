@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements()

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements

    $scope.updatePreviousElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      previousElement = $scope.grade_scheme_elements[index - 1]

      if previousElement
        if currentElement.highest_points
          previousElement.lowest_points = currentElement.highest_points + 1
        else
          previousElement.lowest_points = null

    $scope.updateNextElement = (index)->
      currentElement = $scope.grade_scheme_elements[index]
      nextElement = $scope.grade_scheme_elements[index + 1]

      if nextElement
        if currentElement.lowest_points > 0
          nextElement.highest_points = currentElement.lowest_points - 1
        else
          nextElement.highest_points = null

    $scope.highPointsMin = (index) ->
      element = $scope.grade_scheme_elements[index]

      if element && element.lowest_points >= 0
        element.lowest_points + 1
      else
        null

    $scope.highPointsMax = (index) ->
      prevElement = $scope.grade_scheme_elements[index - 1]
      if prevElement
        prevElement.lowest_points - 1
      else
        null

    $scope.lowPointsMin = (index) ->
      nextElement = $scope.grade_scheme_elements[index + 1]
      if nextElement
        nextElement.highest_points + 1
      else
        null

    $scope.lowPointsMax = (index) ->
      element = $scope.grade_scheme_elements[index]

      if element && element.highest_points > 0
        element.highest_points - 1
      else
        null

    return
]
