@gradecraft.controller 'WeightsCtrl', ['$scope', '$q', 'AssignmentTypeService', ($scope, $q, AssignmentTypeService) ->

  $scope.loading = true

  $scope.init = (student_id)->
    $scope.student_id = student_id
    $scope.services().then(()->
      $scope.loading = false
    )

  $scope.services = ()->
    promises = [AssignmentTypeService.getAssignmentTypes($scope.student_id)]
    return $q.all(promises)


  $scope.assignmentTypes = AssignmentTypeService.assignmentTypes
  $scope.weights = AssignmentTypeService.weights

  # WEIGHTS

  $scope.unusedWeightsRange = ()->
    AssignmentTypeService.unusedWeightsRange()

  $scope.weightsAvailable = ()->
    AssignmentTypeService.weightsAvailable()

]
