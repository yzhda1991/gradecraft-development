@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentTypes().success (gradeLevels)->
      $scope.addAssignmentTypes(gradeLevels)

  PredictorService.getAssignmentsGrades().success (gradeLevels)->
      $scope.addAssignmentsGrades(gradeLevels)

  $scope.addGradelevels = (gradeLevels)->
    d3.select(".grade-levels ul").selectAll("li").data(gradeLevels).enter().append("li")
    .text( (gl)->
      gl.level + " - " + gl.letter + " (" + gl.low_range + ")"
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
