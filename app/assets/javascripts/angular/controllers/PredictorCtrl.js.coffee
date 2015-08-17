@gradecraft.controller 'PredictorCtrl', ['$scope', '$http', '$q', '$filter', 'PredictorService', ($scope, $http, $q, $filter, PredictorService) ->
  # this.id = 'predictorCtrl'
  $scope.assignmentMode = true

  $scope.services = ()->
    promises = [PredictorService.getGradeLevels(),
                PredictorService.getAssignments(),
                PredictorService.getAssignmentTypes(),
                PredictorService.getAssignmentTypeWeights(),
                PredictorService.getBadges(),
                PredictorService.getChallenges()]
    return $q.all(promises)


  $scope.services().then(()->
    $scope.renderGradeLevelGraphics()
  )

  $scope.assignments = PredictorService.assignments
  $scope.assignmentTypes = PredictorService.assignmentTypes
  $scope.gradeLevels = PredictorService.gradeLevels
  $scope.badges = PredictorService.badges
  $scope.weights = PredictorService.weights
  $scope.challenges = PredictorService.challenges
  $scope.icons = PredictorService.icons
  $scope.termFor = PredictorService.termFor

  $scope.passFailPrediction = (grade)->
    prediction = if grade.predicted_score > 0 then PredictorService.termFor.pass else PredictorService.termFor.fail

  $scope.assignmentTypeAtMax = (assignmentType)->
    if $scope.assignmentTypePointExcess(assignmentType) > 0
      return true
    else
      return false

  $scope.articleGraded = (assignment)->
    if assignment.grade.score == null
      return false
    else
      return true

  # Assignments with Score Levels: returns true
  $scope.hasLevels = (assignment)->
    assignment.score_levels.length > 0

  # Assignments with Score Levels: Returns the Level Name if predicted score in range
  $scope.levelNameForAssignmentScore = (assignment)->
    if $scope.hasLevels(assignment)
      closest = $scope.closestScoreLevel(assignment.score_levels,assignment.grade.predicted_score)
      if $scope.inSnapRange(assignment,closest,assignment.grade.predicted_score)
        return closest.name
    return ""

  # Assignments with Score Levels: Returns the Level Name if predicted score in range
  $scope.levelNameForChallengeScore = (challenge)->
    if $scope.hasLevels(challenge)
      closest = $scope.closestScoreLevel(challenge.score_levels,challenge.prediction.points_earned)
      if $scope.inSnapRange(challenge,closest,challenge.prediction.points_earned)
        return closest.name
    return ""

  # Assignments with Score Levels: Defines a snap tolerance and returns true if value is within range
  $scope.inSnapRange = (assignment,scoreLevel,value)->
    tolerance = assignment.grade.point_total * 0.05
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

  # Total points predicted for a collection of assignments
  $scope.assignmentsPointTotal = (assignments)->
    total = 0
    _.each(assignments, (assignment)->
      if assignment.grade.score > 0
        total += assignment.grade.score
      else if ! assignment.pass_fail
        total += assignment.grade.predicted_score
    )
    total

  # Total points predicted for all assignments by assignments type
  # caps the total points at the assignment type max points
  # only calculates the weighted total if weighted is passed in as true
  $scope.assignmentTypePointTotal = (assignmentType, weighted=true)->
    assignments = $scope.assignmentsForAssignmentType($scope.assignments,assignmentType.id)
    total = $scope.assignmentsPointTotal(assignments)
    if assignmentType.student_weightable
      # ignore max value on weightable assignments, even if not calulating the weights
      if weighted
        total = total * assignmentType.student_weight
    else if assignmentType.max_value
      total = if total > assignmentType.max_value then assignmentType.max_value else total
    total

  # Total predicted points above and beyond the assignment type max points
  $scope.assignmentTypePointExcess = (assignmentType)->
    assignments = $scope.assignmentsForAssignmentType($scope.assignments,assignmentType.id)
    total = $scope.assignmentsPointTotal(assignments) - assignmentType.max_value

  # Total points predicted for badges
  $scope.badgesPointTotal = ()->
    total = 0
    _.each($scope.badges,(badge)->
        total += badge.prediction.times_earned * badge.point_total
      )
    total

  # Total points possible to earn from challenges
  $scope.maxChallengePoints = ()->
    total = 0
    _.each($scope.challenges, (challenge)->
      total += challenge.point_total
      )
    total

  # Total points predicted for challenges
  $scope.challengesPointTotal = ()->
    total = 0
    _.each($scope.challenges, (challenge)->
        if challenge.grade.score > 0
          total += challenge.grade.score
        else
          total += challenge.prediction.points_earned
      )
    total

  # Total points predicted for all assignments, badges, and challenges
  $scope.allPointsPredicted = ()->
    total = 0
    _.each($scope.assignmentTypes, (assignmentType)->
        total += $scope.assignmentTypePointTotal(assignmentType)
      )
    total += $scope.badgesPointTotal()
    total += $scope.challengesPointTotal()
    total

  # Total points actually earned to date
  $scope.allPointsEarned = ()->
    total = 0
    _.each($scope.assignments, (assignment)->
      if assignment.grade.score > 0
        total += assignment.grade.score
      )
    _.each($scope.badges,(badge)->
        total += badge.total_earned_points
      )
    total

  $scope.badgeCompleted = (badge)->
    if (badge.point_total == badge.total_earned_points && ! badge.can_earn_multiple_times)
      return true
    else
      return false

  $scope.dueInFuture = (assignment)->
    if assignment.due_at != null && Date.parse(assignment.due_at) >= Date.now()
      return true
    else
      return false

# UI ELEMENTS

  $scope.slider = (article)->
    {
      range: "min"

      #start: (event, ui)->

      slide: (event, ui)->
        slider = ui.handle.parentElement
        articleType = ui.handle.parentElement.dataset.articleType
        if $scope.hasLevels(article)
          closest = $scope.closestScoreLevel(article.score_levels,ui.value)
          if $scope.inSnapRange(article,closest,ui.value)
            event.preventDefault()
            event.stopPropagation()
            angular.element(ui.handle.parentElement).slider("value", closest.value)
            if articleType == 'assignment'
              angular.element("#assignment-" + article.id + "-level .value").text($filter('number')(closest.value) + " / " + $filter('number')(article.grade.point_total))
            else
              angular.element("#challenge-" + article.id + "-level .value").text($filter('number')(closest.value) + " / " + $filter('number')(article.point_total))
          else
            if articleType == 'assignment'
              angular.element("#assignment-" + article.id + "-level .value").text($filter('number')(ui.value) + " / " + $filter('number')(article.grade.point_total))
            else
              angular.element("#challenge-" + article.id + "-level .value").text($filter('number')(ui.value) + " / " + $filter('number')(article.point_total))
      stop: (event, ui)->
        articleType = ui.handle.parentElement.dataset.articleType
        article_id = ui.handle.parentElement.dataset.id
        value = ui.value
        if articleType == 'assignment'
          article.grade.predicted_score = value
          PredictorService.postPredictedGrade(article_id,value)
        else
          article.prediction.points_earned = value
          PredictorService.postPredictedChallenge(article_id,value)
    }

# WEIGHTS

  $scope.unusedWeightsRange = ()->
    _.range($scope.weights.unusedWeights())

  $scope.weightsAvailable = ()->
    $scope.weights.unusedWeights() && $scope.weights.open

# GRAPHICS RENDERING

  $scope.GraphicsStats = ()->
    totalPoints = $scope.gradeLevels.total_points
    width = parseInt(d3.select("#predictor-graphic").style("width")) - 20
    height = parseInt(d3.select("#predictor-graphic").style("height"))
    stats = {
      width: width
      height: height
      padding: 10
      # Maximum possible points for the course
      totalPoints: totalPoints
      #scale for placing elements along the x axis
      scale: d3.scale.linear().domain([0,totalPoints]).range([0,width])
    }

  # Loads the grade points values and corresponding grade levels name/letter-grade into the predictor graphic
  $scope.renderGradeLevelGraphics = ()->
    grade_scheme_elements = $scope.gradeLevels.grade_scheme_elements
    svg = d3.select("#svg-grade-levels")
    stats = $scope.GraphicsStats()
    padding = stats.padding
    scale = stats.scale
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
              "translate(" + scale(gse.low_range) + padding + "," + 5 + ")")
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
      .attr("transform": "translate(" + padding + "," + (stats.height - 55) + ")")
      .call(axis)

  $scope.svgEarnedBarWidth = ()->
    width = $scope.GraphicsStats().scale($scope.allPointsEarned())
    width = width || 0

  $scope.svgPredictedBarWidth = ()->
    width = $scope.GraphicsStats().scale($scope.allPointsPredicted())
    width = width || 0

  return
]
