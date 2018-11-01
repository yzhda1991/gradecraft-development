# Manages state of AssignmentsTypes and Weights including API calls.
# Can be used independently, or via another service (see PredictorService)

gradecraft.factory 'AssignmentTypeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  update = {}
  assignmentTypes = []

  weights = {
    unusedWeights: ()->
      return 0
  }

  assignmentType = () -> assignmentTypes[0]

  termFor = (article)->
    GradeCraftAPI.termFor(article)


  #---------------- Assignment Type Point Calculations ------------------------#

  # multiply points by the student's assignment type weight if weighted
  # points defaults to zero for generic predictor
  weightedPoints = (assignmentType, points=0)->
    if assignmentType.student_weightable
      points * assignmentType.student_weight
    else
      points

  weightedEarnedPoints = (assignmentType)->
    weightedPoints(assignmentType, assignmentType.final_points_for_student)

  weightedTotalPoints = (assignmentType)->
    total = weightedPoints(assignmentType, assignmentType.total_points)
    if assignmentType.is_capped
      total = if total > assignmentType.total_points then assignmentType.total_points else total
    total

  #---------------- Weights Calculations --------------------------------------#

  # returns array [0, 1, 2, 3] for iterating coins
  unusedWeightsRange = ()->
    _.range(weights.unusedWeights())

  weightsAvailable = ()->
    weights.unusedWeights() && weights.open

  weightsAvailableForArticle = (article)->
    if article.student_weight < 1
      return false if weights.unusedTypes() < 1
    if weights.max_weights_per_assignment_type
      article.student_weight < weights.max_weights_per_assignment_type && weights.unusedWeights() > 0
    else
      weights.unusedWeights() > 0


  #----------------- API Calls ------------------------------------------------#

  getAssignmentType = (id) ->
    $http.get("/api/assignment_types/#{id}").then(
      (response) ->
        GradeCraftAPI.addItem(assignmentTypes, "assignment_types", response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getAssignmentTypes = ()->
    $http.get("/api/assignment_types").success((res)->
      _.each(res.data, (assignment_type)->
        assignmentTypes.push(assignment_type.attributes)
      )
      GradeCraftAPI.setTermFor("assignmentType", res.meta.term_for_assignment_type)
      GradeCraftAPI.setTermFor("weights", res.meta.term_for_weights)
      update.weights = res.meta.update_weights
      weights.open = !res.meta.weights_close_at ||
        new Date(res.meta.weights_close_at) >= Date.now()
      weights.total_weights = res.meta.total_weights
      weights.weights_close_at = res.meta.weights_close_at
      weights.max_weights_per_assignment_type = res.meta.max_weights_per_assignment_type
      weights.max_assignment_types_weighted = res.meta.max_assignment_types_weighted

      weights.unusedWeights = ()->
        used = 0
        _.each(assignmentTypes,(at)->
          if at.student_weightable
            used += at.student_weight
        )
        weights.total_weights - used
      weights.unusedTypes = ()->
        types = 0
        _.each(assignmentTypes, (at)->
          if at.student_weight > 0
            types += 1
        )
        weights.max_assignment_types_weighted - types
      )

  postAssignmentTypeWeight = (id, value)->
    if update.weights
      $http.post('/api/assignment_types/' + id + '/assignment_type_weights', weight: value).success(
          (data)->
            console.log(data);
        ).error(
          (data)->
            console.log(data);
        )

  return {
      termFor: termFor

      assignmentType: assignmentType
      assignmentTypes: assignmentTypes
      weights: weights

      weightedPoints: weightedPoints
      weightedEarnedPoints: weightedEarnedPoints
      weightedTotalPoints: weightedTotalPoints

      unusedWeightsRange: unusedWeightsRange
      weightsAvailable: weightsAvailable
      weightsAvailableForArticle: weightsAvailableForArticle

      getAssignmentType: getAssignmentType
      getAssignmentTypes: getAssignmentTypes
      postAssignmentTypeWeight: postAssignmentTypeWeight
  }
]
