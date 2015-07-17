@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  $scope.assignmentMode = true

  # Alternate method:
  #http://stackoverflow.com/questions/21310964/angularjs-q-all
  #https://github.com/kriskowal/q/wiki/API-Reference
  $scope.serviceStatus = (()->
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
    $scope.serviceStatus.add("gradeLevels")
    if $scope.serviceStatus.complete()
      $scope.integration()

  PredictorService.getAssignments().success (assignments)->
    $scope.serviceStatus.add("assignments")
    PredictorService.getAssignmentTypes().success (assignmentTypes)->
      $scope.addAssignmentTypes(assignmentTypes)
      $scope.serviceStatus.add("assignmentTypes")
      if $scope.serviceStatus.complete()
        $scope.integration()

  $scope.addGradelevels = (gradeLevels)->
    $scope.gradeLevels = gradeLevels

  $scope.addAssignmentTypes = (assignmentTypes)->
    $scope.assignmentTypes = assignmentTypes.assignment_types

  $scope.assignments = PredictorService.assignments
  $scope.icons = PredictorService.icons

  $scope.passFailPrediction = (grade)->
    prediction = if grade.predicted_score > 0 then PredictorService.termFor.pass else PredictorService.termFor.fail

  $scope.slider = (assignment)->
    {
      range: "min"

      #start: (event, ui)->

      slide: (event, ui)->
        slider = ui.handle.parentElement
        # scoreNames = JSON.parse(slider.dataset.scoreLevelNames)
        # scoreValues = JSON.parse(slider.dataset.scoreLevelValues)
        if $scope.hasLevels(assignment)
          closest = $scope.closestScoreLevel(assignment.score_levels,ui.value)
          angular.element("#assignment-" + assignment.id + "-level").text(closest.level)
          angular.element("#assignment-" + assignment.id + "-value").text(ui.value)
          #if Math.abs(ui.value - closest)
            # ...

          # closest = null
          # _.each(scoreValues, (val,i)->
          #   if (closest == null || Math.abs(val - ui.value) < Math.abs(closest - ui.value))
          #     closest = val
          # )
          # assignment.grade.predicted_score = closest
          # $(ui.handle.parentElement).slider("value", closest)

      stop: (event, ui)->
        assignment_id = ui.handle.parentElement.dataset.id
        value = ui.value
        PredictorService.postPredictedScore(assignment_id,value)

    }

  #$scope.withinScoreLevelSnapRange(assignment,scoreLevelValue,value)
    #rangeLImit = assignment.point_total / 10

  $scope.closestScoreLevel = (scoreLevels,value)->
    closest = null
    _.each(scoreLevels, (lvl,i)->
      if (closest == null || Math.abs(lvl.value - value) < Math.abs(scoreLevels[closest].value - value))
        closest = i
    )
    return scoreLevels[closest]

  $scope.hasLevels = (assignment)->
    assignment.score_levels.length > 0

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
