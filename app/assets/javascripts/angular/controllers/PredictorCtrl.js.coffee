@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  PredictorService.getGradeLevels().success (gradeLevels)->
      $scope.addGradelevels(gradeLevels)

  PredictorService.getAssignmentTypes().success (assignmentTypes)->
      $scope.addAssignmentTypes(assignmentTypes)

  PredictorService.getAssignmentsGrades().success (assignmentsGrades)->
      $scope.addAssignmentsGrades(assignmentsGrades)

  $scope.addGradelevels = (gradeLevels)->
    total_points = gradeLevels.total_points
    grade_scheme_elements = gradeLevels.grade_scheme_elements
    svg = d3.select("#grade-levels").append("svg").attr("width", "100%").attr("height", 100)
    scale = d3.scale.linear().domain([0,total_points]).range([0,100])

    svg.selectAll('circle').data(grade_scheme_elements).enter().append('circle')
      .attr("cx", (d)->
        scale(d.low_range) + "%")
      .attr("cy", 10)
      .attr("r", 10)
    # d3.select(".grade-levels ul").selectAll("li").data(gradeLevels).enter().append("li")
    # .text( (gl)->
    #   gl.level + " - " + gl.letter + " (" + gl.low_range + ")"
    # )

  $scope.addAssignmentTypes = (assignmentTypes)->
    # domATS = angular.element( document.querySelector( '#assignment-types' ) )
    # angular.forEach(assignmentTypes, (at, index)->
    #   console.log(at)
    # )
    $scope.assignmentTypes = assignmentTypes

  $scope.addAssignmentsGrades = (assignmentsGrades)->
    angular.forEach(assignmentsGrades, (ag, index)->
      #console.log(ag)
    )
  return
]
