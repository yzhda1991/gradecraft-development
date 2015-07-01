@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', 'AssociateAssignmentsFilter', ($scope, $http, PredictorService, AssociateAssignmentsFilter) ->

  $scope.assignmentMode = true

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentsGrades().success (assignmentsGrades)->
    $scope.addAssignmentsGrades(assignmentsGrades)
    PredictorService.getAssignmentTypes().success (assignmentTypes)->
      $scope.addAssignmentTypes(assignmentTypes)
      $scope.associatedAssignments()

  $scope.addGradelevels = (gradeLevels)->
    # d3.select(".grade-levels ul").selectAll("li").data(gradeLevels).enter().append("li")
    # .text( (gl)->
    #   gl.level + " - " + gl.letter + " (" + gl.low_range + ")"
    # )

  $scope.addAssignmentTypes = (assignmentTypes)->
    $scope.assignmentTypes = assignmentTypes

  $scope.addAssignmentsGrades = (assignmentsGrades)->
    $scope.assignmentGrades = assignmentsGrades

  $scope.associateAssignments = (assignmentType, assignments) ->
    filteredList = []
    angular.forEach(assignments, (assignment) ->
      if(assignment.assignment_type_id == assignmentType.id)
        filteredList[assignment.position] = assignment
    )
    debugger
    return filteredList

  $scope.associatedAssignments = ()->
    associated = []
    angular.forEach($scope.assignmentTypes, (assignment_type) ->
      associated.push($scope.associateAssignments(assignment_type, $scope.assignmentGrades))
    )
  return
]
