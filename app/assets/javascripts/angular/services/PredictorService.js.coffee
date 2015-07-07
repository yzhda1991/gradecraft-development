@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    getGradeLevels = ()->
      $http.get("/predictor_grade_levels/")

    getAssignmentTypes = (assignmentId)->
      $http.get("predictor_assignment_types")

    getAssignments = (assignmentId)->
      $http.get("predictor_assignments")


    return {
        getGradeLevels: getGradeLevels,
        getAssignmentTypes: getAssignmentTypes,
        getAssignments: getAssignments
    }
]
