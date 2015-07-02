@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  $scope.assignmentMode = true

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentsGrades().success (assignmentsGrades)->
    $scope.addAssignmentsGrades(assignmentsGrades)

  # PredictorService.getAssignmentTypes().success (assignmentTypes)->
  #   $scope.addAssignmentTypes(assignmentTypes)
  #   $scope.associatedAssignments()

  $scope.addGradelevels = (gradeLevels)->
    total_points = gradeLevels.total_points
    grade_scheme_elements = gradeLevels.grade_scheme_elements
    svg = d3.select("#svg-grade-levels")
    scale = d3.scale.linear().domain([0,total_points]).range([0,100])

    svg.selectAll('circle').data(grade_scheme_elements).enter().append('circle')
      .attr("cx", (gse)->
        scale(gse.low_range) + "%")
      .attr("cy", 20)
      .attr("r", 5)
      .on("mouseover", (gse)->
        d3.select(".grade_scheme-label-" + gse.low_range).style("visibility", "visible"))
      .on("mouseout", (gse)->
        d3.select(".grade_scheme-label-" + gse.low_range).style("visibility", "hidden"))

      #   return tooltip.style("top", (event.pageY-30)+"px").style("left",(event.pageX+10)+"px"))
      # .on("mouseout", ()->
      #   return tooltip.style("visibility", "hidden"))

    svg.selectAll('text').data(grade_scheme_elements).enter().append('text')
      .text( (gse)->
        gse.level + " - " + gse.letter + " (" + gse.low_range + ")")
      .attr("x", (gse)->
        scale(gse.low_range) + "%")
      .attr("y", 15)
      .attr("class", (gse)->
        "grade_scheme-label-" + gse.low_range)
      .style("visibility", "hidden")

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
    return filteredList

  $scope.associatedAssignments = ()->
    associated = []
    angular.forEach($scope.assignmentTypes, (assignment_type) ->
      associated.push($scope.associateAssignments(assignment_type, $scope.assignmentGrades))
    )
  return
]
