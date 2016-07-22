# Manages state of Assignments including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'AssignmentService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

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
  getAssignments = (studentId)->
    $http.get(GradeCraftAPI.uriPrefix(studentId) + 'predicted_earned_grades').success( (res)->
      GradeCraftAPI.loadMany(assignments,res)
      GradeCraftAPI.setTermFor("assignment", res.meta.term_for_assignment)
      GradeCraftAPI.setTermFor("pass", res.meta.term_for_pass)
      GradeCraftAPI.setTermFor("fail", res.meta.term_for_fail)
      update.assignments = res.meta.update_assignments
    )

  # PUT a predicted earned grade for assignment
  postPredictedAssignment = (assignment)->
    if update.assignments
      $http.put(
        '/api/predicted_earned_grades/' + assignment.prediction.id, predicted_points: assignment.prediction.predicted_points
        ).success(
          (data)->
            console.log(data);
        ).error(
          (data)->
            console.log(data);
        )

  return {
      termFor: termFor
      assignmentsSubsetPredictedPoints: assignmentsSubsetPredictedPoints
      assignmentsPredictedPoints: assignmentsPredictedPoints
      getAssignments: getAssignments
      postPredictedAssignment: postPredictedAssignment
      assignments: assignments
  }
]
