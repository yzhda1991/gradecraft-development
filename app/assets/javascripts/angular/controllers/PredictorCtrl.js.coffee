@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentTypes().success (gradeLevels)->
      $scope.addAssignmentTypes(gradeLevels)

  PredictorService.getAssignmentsGrades().success (gradeLevels)->
      $scope.addAssignmentsGrades(gradeLevels)

  $scope.addGradelevels = (gradeLevels)->
    angular.forEach(gradeLevels, (gl, index)->
      console.log(gl);
    )

  $scope.addAssignmentTypes = (AssignmentTypes)->
    angular.forEach(AssignmentTypes, (at, index)->
      console.log(at);
    )

  $scope.addAssignmentsGrades = (AssignmentsGrades)->
    angular.forEach(AssignmentsGrades, (ag, index)->
      console.log(ag);
    )
]
