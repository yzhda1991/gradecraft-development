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
    svg = d3.select("#svg-grade-levels")
    width = parseInt(d3.select("#predictor-graphic").style("width")) - 20
    height = parseInt(d3.select("#predictor-graphic").style("height"))
    padding = 10
    scale = d3.scale.linear().domain([0,total_points]).range([0,width])
    axis = d3.svg.axis().scale(scale).orient("bottom")
    g = svg.selectAll('g').data(grade_scheme_elements).enter().append('g')
            .attr("transform", (gse)->
              "translate(" + scale(gse.low_range) + padding + "," + 30 + ")")
            .on("mouseover", (gse)->
              d3.select(".grade_scheme-label-" + gse.low_range).style("visibility", "visible"))
            .on("mouseout", (gse)->
              d3.select(".grade_scheme-label-" + gse.low_range).style("visibility", "hidden"))
    g.append("path")
      .attr("d", "M3,2.492c0,1.392-1.5,4.48-1.5,4.48S0,3.884,0,2.492c0-1.392,0.671-2.52,1.5-2.52S3,1.101,3,2.492z")
    txt = d3.select("#svg-grade-level-text").selectAll('g').data(grade_scheme_elements).enter()
            .append('g')
            .attr("class", (gse)->
              "grade_scheme-label-" + gse.low_range)
            .style("visibility", "hidden")
            .attr("transform", (gse)->
              "translate(" + scale(gse.low_range) + padding + "," + 50 + ")")
    txt.append("rect")
      .attr("width", 150)
      .attr("height", 20)
      .attr("fill",'black')
    txt.append('text')
      .text( (gse)->
        gse.level + " (" + gse.letter + ")")
      .attr("y","15")
      .attr("font-family","Verdana")
      .attr("fill", "#FFFFFF")
    d3.select("svg").append("g")
      .attr("class": "grade-point-axis")
      .attr("transform": "translate(" + padding + "," + (height - 20) + ")")
      .call(axis)


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
