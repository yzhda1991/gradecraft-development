@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  $scope.assignmentMode = true

  $scope.predictorServices = (()->
        gradeLevels : false
        assignmentTypes : false
        assignments : false

        add : (service)->
          if service == "gradeLevels"
            self.gradeLevels = true
          else if service == "assignmentTypes"
            self.assignmentTypes = true
          else if service == "assignments"
            self.assignments = true
        complete : ()->
          if self.gradeLevels && self.assignmentTypes && self.assignments
            return true
          else
            return false
  )()

  PredictorService.getGradeLevels().success (gradeLevels)->
    $scope.addGradelevels(gradeLevels)
    $scope.renderGradeLevelGraphics()
    $scope.predictorServices.add("gradeLevels")
    if $scope.predictorServices.complete()
      $scope.integration()

  PredictorService.getAssignments().success (assignments)->
    $scope.addAssignments(assignments)
    $scope.predictorServices.add("assignments")
    PredictorService.getAssignmentTypes().success (assignmentTypes)->
      $scope.addAssignmentTypes(assignmentTypes)
      $scope.predictorServices.add("assignmentTypes")
      if $scope.predictorServices.complete()
        $scope.integration()

  $scope.addGradelevels = (gradeLevels)->
    $scope.gradeLevels = gradeLevels

  $scope.addAssignmentTypes = (assignmentTypes)->
    $scope.assignmentTypes = assignmentTypes.assignment_types

  $scope.addAssignments = (assignments)->
    $scope.assignments = assignments.assignments
    $scope.termFor = (term)->
      switch term.toLowerCase()
        when "assignment" then return assignments.term_for_assignment
        when "pass" then return assignments.term_for_pass
        when "fail" then return assignments.term_for_fail
        else return ""
    $scope.passFailPrediction = (grade)->
      prediction = if grade.predicted_score > 0 then $scope.termFor("pass") else $scope.termFor("fail")

  $scope.slider =
    { 'options': {
        range: "min",

        #start: (event, ui)->

        slide: (event, ui)->
          scoreNames = JSON.parse(ui.handle.parentElement.dataset.scoreLevelNames)
          scoreValues = JSON.parse(ui.handle.parentElement.dataset.scoreLevelValues)
          if(scoreValues.length > 0)
            closest = null
            $.each(scoreValues, ()->
              if (closest == null || Math.abs(this - ui.value) < Math.abs(closest - ui.value))
                closest = this
            )
            console.log(closest);
            #$(this).slider("value", closest);

        stop: (event, ui)->
          assignment_id = ui.handle.parentElement.dataset.id
          value = ui.value
          PredictorService.postPredictedScore(assignment_id,value)
      }
    }

  $scope.scoreLevelValues = (assignment)->
    _.map(assignment.score_levels,(level)->
        level.value
      )
  $scope.scoreLevelNames = (assignment)->
    _.map(assignment.score_levels,(level)->
        level.name
      )

  # Filter the assignments, return just the assignments for the assignment type
  $scope.assignmentsForAssignmentType = (assignments,assignmentType)->
    _.where(assignments, {assignment_type_id: assignmentType})

  $scope.assignmentDueInFuture = (assignment)->
    if assignment.due_at != null && Date.parse(assignment.due_at) >= Date.now()
      return true
    else
      return false

  $scope.integration = ()->
    console.log("holy schnikes!");

  # Loads the grade points values and corresponding grade levels name/letter-grade into the predictor graphic
  $scope.renderGradeLevelGraphics = ()->
    totalPoints = $scope.gradeLevels.total_points
    grade_scheme_elements = $scope.gradeLevels.grade_scheme_elements
    svg = d3.select("#svg-grade-levels")
    width = parseInt(d3.select("#predictor-graphic").style("width")) - 20
    height = parseInt(d3.select("#predictor-graphic").style("height"))
    padding = 10
    scale = d3.scale.linear().domain([0,totalPoints]).range([0,width])
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

  return
]
