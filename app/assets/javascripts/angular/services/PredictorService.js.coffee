@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    termFor = {
        assignment: ""
        pass: ""
        fail: ""
    }
    assignments = []
    assignmentTypes = []
    gradeLevels = {}
    icons = ["required","late"]

    getGradeLevels = ()->
      $http.get("/predictor_grade_levels/").success((data)->
        angular.copy(data,gradeLevels)
      )

    getAssignmentTypes = (assignmentId)->
      $http.get("predictor_assignment_types").success((data)->
        angular.copy(data.assignment_types, assignmentTypes)
      )
    getAssignments = (assignmentId)->
      $http.get("predictor_assignments").success( (data)->
        angular.copy(data.assignments,assignments)
        angular.copy({
          assignment: data.term_for_assignment
          pass: data.term_for_pass
          Pass: data.term_for_pass
          fail: data.term_for_fail
          Fail: data.term_for_fail
        },termFor)
      )

    postPredictedScore = (assignment_id,value)->
      $http.post('/assignments/' + assignment_id + '/grades/predict_score', predicted_score: value).success(
        (data)->
          console.log(data);
        ).error(
        (data)->
          console.log(data);
        )

    return {
        getGradeLevels: getGradeLevels
        getAssignmentTypes: getAssignmentTypes
        getAssignments: getAssignments
        postPredictedScore: postPredictedScore
        assignments: assignments
        assignmentTypes: assignmentTypes
        gradeLevels: gradeLevels
        termFor: termFor
        icons: icons
    }
]
