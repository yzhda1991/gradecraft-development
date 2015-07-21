@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    termFor = {
        assignment: ""
        pass: ""
        fail: ""
        badges: ""
    }
    gradeLevels = {}
    assignments = []
    assignmentTypes = []
    badges = []
    icons = ["required","late","info"]

    getGradeLevels = ()->
      $http.get("predictor_grade_levels").success((data)->
        angular.copy(data,gradeLevels)
      )

    getAssignmentTypes = (assignmentId)->
      $http.get("predictor_assignment_types").success((data)->
        angular.copy(data.assignment_types, assignmentTypes)
      )

    getAssignments = (assignmentId)->
      $http.get("predictor_assignments").success( (data)->
        angular.copy(data.assignments,assignments)
        termFor.assignment = data.term_for_assignment
        termFor.pass = data.term_for_pass
        termFor.Pass = data.term_for_pass
        termFor.pass = data.term_for_pass
        termFor.fail = data.term_for_fail
        termFor.Fail = data.term_for_fail
      )

    getBadges = ()->
      $http.get('predictor_badges').success( (data)->
          angular.copy(data.badges,badges)
          termFor.badges = data.term_for_badges
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
        getBadges: getBadges
        postPredictedScore: postPredictedScore
        assignments: assignments
        assignmentTypes: assignmentTypes
        gradeLevels: gradeLevels
        badges: badges
        termFor: termFor
        icons: icons
    }
]
