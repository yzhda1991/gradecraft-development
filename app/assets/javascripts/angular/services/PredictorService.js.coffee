@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    getGradeLevels = ()->
      $http.get("/predictor_grade_levels/")

    getAssignmentTypes = (assignmentId)->
      $http.get("predictor_assignment_types")

    getAssignmentsGrades = (assignmentId)->
      $http.get("predictor_assignments_grades")


    return {
        getGradeLevels: getGradeLevels,
        getAssignmentTypes: getAssignmentTypes,
        getAssignmentsGrades: getAssignmentsGrades
    }
]
