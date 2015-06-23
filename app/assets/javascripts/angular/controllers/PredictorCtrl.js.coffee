@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentTypes().success (assignmentTypes)->
      $scope.addAssignmentTypes(assignmentTypes)

  PredictorService.getAssignmentsGrades().success (assignmentsGrades)->
      $scope.addAssignmentsGrades(assignmentsGrades)

  $scope.addGradelevels = (gradeLevels)->
    d3.select(".grade-levels ul").selectAll("li").data(gradeLevels).enter().append("li")
    .text( (gl)->
      gl.level + " - " + gl.letter + " (" + gl.low_range + ")"
    )

  $scope.addAssignmentTypes = (assignmentTypes)->
    domATS = angular.element( document.querySelector( '#assignment-types' ) )
    angular.forEach(assignmentTypes, (at, index)->
      console.log(at)
    )

  $scope.addAssignmentsGrades = (assignmentsGrades)->
    angular.forEach(assignmentsGrades, (ag, index)->
      console.log(ag)
    )
]
