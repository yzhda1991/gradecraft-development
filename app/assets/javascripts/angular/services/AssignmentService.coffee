# Manages state of Assignments including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'AssignmentService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', 'RubricService', ($http, GradeCraftAPI, GradeCraftPredictionAPI, RubricService) ->

  assignments = []
  update = {}

  # managing a single assignment resource,
  # must be a function for Angular two-way binding to work
  assignment = ()->
    assignments[0]

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  # Total points earned and predicted for a collection of assignments
  # Used to total by Assignment Type
  assignmentsSubsetPredictedPoints = (subset)->
    total = 0
    _.each(subset, (assignment)->
      # use raw score to keep weighting calculation on assignment type level
      if assignment.grade.final_points != null
        if ! assignment.grade.is_excluded
          total += assignment.grade.final_points
      else if ! assignment.pass_fail && ! assignment.closed_without_submission
        if !(assignment.is_closed_without_submission || assignment.is_closed_by_condition)
          total += assignment.prediction.predicted_points || 0
    )
    total

  # Total points earned and predicted for all assignments
  assignmentsPredictedPoints = ()->
    assignmentsSubsetPredictedPoints(assignments)

  #------ API Calls -----------------------------------------------------------#

  # GET single assignment, will be the only item in the assignments array
  getAssignment = (assignmentId)->
    $http.get('/api/assignments/' + assignmentId).then(
      (response)->
        GradeCraftAPI.addItem(assignments, "assignments", response.data)
        if response.data.data.relationships && response.data.data.relationships.rubric
          RubricService.getRubric(response.data.data.relationships.rubric.data.id)

        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
        GradeCraftAPI.logResponse(response)
      (response)->
        GradeCraftAPI.logResponse(response)
    )

  # GET index list of assignments including a student's grades and predictions
  getAssignments = ()->
    $http.get('/api/assignments').then(
      (response)->
        GradeCraftAPI.loadMany(assignments, response.data, {"include" : ['prediction','grade']})
        _.each(assignments, (assignment)->
          # add null prediction and grades when JSON contains none
          assignment.prediction = { predicted_points: 0 } if !assignment.prediction
          assignment.grade = { score: null, final_points: null, is_excluded: false } if !assignment.grade

          # Iterate through all Assignments that are conditions,
          # If they are closed_without_submission,
          # flag this assignment to be closed as well
          if assignment.conditional_assignment_ids
            assignment.is_closed_by_condition = false
            _.each(assignment.conditional_assignment_ids, (id)->
              a = _.find(assignments, {id: id})
              if a && a.is_closed_without_submission == true
                assignment.is_closed_by_condition = true
            )
        )
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
        update.predicted_earned_grades = response.data.meta.allow_updates
        GradeCraftAPI.logResponse(response)
      (response)->
        GradeCraftAPI.logResponse(response)
    )

  # Assignment Attributes are updated individually from checkboxes on the
  # settings page. Note that the updated attribute might be different from
  # the one passed in by json and optimised for the predictor:
  # example: required vs. is_required
  updateAssignmentAttribute = (id, attribute, state) ->
    params = { "#{attribute}" : state }
    assignment = _.find(assignments, {id: id})
    $http.put("/api/assignments/#{id}", assignment: params).then(
      (response) ->
        assignment.attribute = state
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  # PUT a predicted earned grade for assignment
  postPredictedAssignment = (assignment)->
    if update.predicted_earned_grades
      requestParams = {
        "predicted_earned_grade": {
          "assignment_id": assignment.id,
          "predicted_points": assignment.prediction.predicted_points
        }}
      if assignment.prediction.id
        GradeCraftPredictionAPI.updatePrediction(assignment, '/api/predicted_earned_grades/' + assignment.prediction.id, requestParams)
      else
        GradeCraftPredictionAPI.createPrediction(assignment, '/api/predicted_earned_grades/', requestParams)

  return {
      termFor: termFor
      assignmentsSubsetPredictedPoints: assignmentsSubsetPredictedPoints
      assignmentsPredictedPoints: assignmentsPredictedPoints
      getAssignments: getAssignments
      getAssignment: getAssignment
      updateAssignmentAttribute: updateAssignmentAttribute
      postPredictedAssignment: postPredictedAssignment
      assignments: assignments
      assignment: assignment
  }
]
