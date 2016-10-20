# Manages state of Assignments including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'AssignmentService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', ($http, GradeCraftAPI, GradeCraftPredictionAPI) ->

  assignments = []
  update = {}

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
      else if ! assignment.pass_fail && ! assignment.closed_without_sumbission
        total += assignment.prediction.predicted_points
    )
    total

  # Total points earned and predicted for all assignments
  assignmentsPredictedPoints = ()->
    assignmentsSubsetPredictedPoints(assignments)

  #------ API Calls -----------------------------------------------------------#

  # GET index list of assignments including a student's grades and predictions
  getAssignments = ()->
    $http.get('/api/assignments').success( (response)->
      GradeCraftAPI.loadMany(assignments, response, {"include" : ['prediction','grade']})
      _.each(assignments, (assignment)->
        # add null prediction and grades when JSON contains none
        assignment.prediction = { predicted_points: 0 } if !assignment.prediction
        assignment.grade = { score: null, final_points: null, is_excluded: false } if !assignment.grade
      )

      GradeCraftAPI.setTermFor("assignment", response.meta.term_for_assignment)
      GradeCraftAPI.setTermFor("pass", response.meta.term_for_pass)
      GradeCraftAPI.setTermFor("fail", response.meta.term_for_fail)
      update.predicted_earned_grades = response.meta.allow_updates
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
      postPredictedAssignment: postPredictedAssignment
      assignments: assignments
  }
]
