@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', '$q', '$filter', 'PredictorService', ($scope, $http, $q, $filter, PredictorService) ->

  $scope.assignmentMode = true

  $scope.services = ()->
    promises = [PredictorService.getGradeLevels(),
                PredictorService.getAssignments(),
                PredictorService.getAssignmentTypes(),
                PredictorService.getBadges()]
    return $q.all(promises)


  $scope.services().then(()->
    $scope.renderGradeLevelGraphics()
  )

  $scope.assignments = PredictorService.assignments
  $scope.assignmentTypes = PredictorService.assignmentTypes
  $scope.gradeLevels = PredictorService.gradeLevels
  $scope.badges = PredictorService.badges
  $scope.icons = PredictorService.icons
  $scope.termFor = PredictorService.termFor

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
            angular.element("#assignment-" + assignment.id + "-level .value").text($filter('number')(closest.value) + " / " + $filter('number')(assignment.point_total))
          else
            angular.element("#assignment-" + assignment.id + "-level .value").text($filter('number')(ui.value) + " / " + $filter('number')(assignment.point_total))

      stop: (event, ui)->
        assignment_id = ui.handle.parentElement.dataset.id
        value = ui.value
        assignment.grade.predicted_score = value
        PredictorService.postPredictedScore(assignment_id,value)
    }

  # TODO: update with new is_graded logic!
  $scope.assignmentGraded = (assignment)->
    assignment.grade.status == "Graded"

  # Assignments with Score Levels: returns true
  $scope.hasLevels = (assignment)->
    assignment.score_levels.length > 0

  # Assignments with Score Levels: Returns the Level Name if predicted score in range
  $scope.levelNameForScore = (assignment)->
    if $scope.hasLevels(assignment)
      closest = $scope.closestScoreLevel(assignment.score_levels,assignment.grade.predicted_score)
      if $scope.inSnapRange(assignment,closest,assignment.grade.predicted_score)
        return closest.name
    return ""

  # Assignments with Score Levels: Defines a snap tolerance and returns true if value is within range
  $scope.inSnapRange = (assignment,scoreLevel,value)->
    tolerance = assignment.point_total * 0.05
    if Math.abs(scoreLevel.value - value) <= tolerance
      return true
    else
      return false

  # Assignments with Score Levels: returns closest score level
  $scope.closestScoreLevel = (scoreLevels,value)->
    closest = null
    _.each(scoreLevels, (lvl,i)->
      if (closest == null || Math.abs(lvl.value - value) < Math.abs(scoreLevels[closest].value - value))
        closest = i
    )
    return scoreLevels[closest]

  # Filter the assignments, return just the assignments for the assignment type
  $scope.assignmentsForAssignmentType = (assignments,id)->
    _.where(assignments, {assignment_type_id: id})

  $scope.assignmentTypePointTotal = (id)->
    assignments = $scope.assignmentsForAssignmentType($scope.assignments,id)
    total = 0
    _.each(assignments, (assignment)->
      if assignment.grade.score > 0
        total += assignment.grade.score
      else if ! assignment.pass_fail
        total += assignment.grade.predicted_score
    )
    total

  $scope.badgesPointTotal = ()->
    total = 0
    _.each($scope.badges,(badge)->
        total += badge.prediction.times_earned * badge.point_total
      )
    total

  $scope.badgeCompleted = (badge)->
    if (badge.point_total == badge.total_earned_points && ! badge.can_earn_multiple_times)
      return true
    else
      return false

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
