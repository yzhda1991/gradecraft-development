@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', 'PredictorService', ($scope, $http, PredictorService) ->

  $scope.assignmentMode = true

  PredictorService.getAssignments()

  PredictorService.getAssignmentTypes()

  PredictorService.getGradeLevels().success (gradeLevels)->
    $scope.renderGradeLevelGraphics()

  $scope.assignments = PredictorService.assignments
  $scope.assignmentTypes = PredictorService.assignmentTypes
  $scope.gradeLevels = PredictorService.gradeLevels
  $scope.icons = PredictorService.icons

  $scope.passFailPrediction = (grade)->
    prediction = if grade.predicted_score > 0 then PredictorService.termFor.pass else PredictorService.termFor.fail

  $scope.slider = (assignment)->
    {
      range: "min"

      #start: (event, ui)->

      slide: (event, ui)->
        slider = ui.handle.parentElement

        if $scope.hasLevels(assignment)
          closest = $scope.closestScoreLevel(assignment.score_levels,ui.value)
          if $scope.inSnapRange(assignment,closest,ui.value)
            event.preventDefault()
            event.stopPropagation()
            angular.element(ui.handle.parentElement).slider("value", closest.value)
            #angular.element("#assignment-" + assignment.id + "-level .name").text(closest.name)
            angular.element("#assignment-" + assignment.id + "-level .value").text(closest.value)
          else
            #angular.element("#assignment-" + assignment.id + "-level .name").text(" ")
            angular.element("#assignment-" + assignment.id + "-level .value").text(ui.value)

      stop: (event, ui)->
        assignment_id = ui.handle.parentElement.dataset.id
        value = ui.value
        PredictorService.postPredictedScore(assignment_id,value)

    }

  $scope.levelNameForScore = (assignment)->
    if $scope.hasLevels(assignment)
      closest = closestScoreLevel(assignment.score_levels,assignment.grade.predicted_score)
      if inSnapRange(assignment,closest,assignment.grade.predicted_score)
        return closest.name
    return ""

  $scope.inSnapRange = (assignment,scoreLevel,value)->
    tolerance = assignment.point_total * 0.05
    if Math.abs(scoreLevel.value - value) <= tolerance
      return true
    else
      return false


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
  $scope.assignmentsForAssignmentType = (assignments,id)->
    _.where(assignments, {assignment_type_id: id})

  $scope.assignmentDueInFuture = (assignment)->
    if assignment.due_at != null && Date.parse(assignment.due_at) >= Date.now()
      return true
    else
      return false

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
