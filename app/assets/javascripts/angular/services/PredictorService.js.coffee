@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    getGradeLevels = ()->
      $http.get("/predictor_grade_levels/")

    getAssignmentTypes = (assignmentId)->
      $http.get("predictor_assignment_types")

    getAssignments = (assignmentId)->
      $http.get("predictor_assignments")


    postPredictedScore = (assignment_id,value)->
      $http.post('/assignments/' + assignment_id + '/grades/predict_score', predicted_score: value)

    return {
        getGradeLevels: getGradeLevels,
        getAssignmentTypes: getAssignmentTypes,
        getAssignments: getAssignments,
        postPredictedScore: postPredictedScore
    }
]
