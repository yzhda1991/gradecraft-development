@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    termFor = {
        assignment: ""
        pass: ""
        fail: ""
        badges: ""
        challenges: ""
    }
    gradeLevels = {}
    assignments = []
    assignmentTypes = []
    badges = []
    challenges = []
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

    getChallenges = ()->
      $http.get('predictor_challenges').success( (data)->
          angular.copy(data.challenges,challenges)
          termFor.challenges = data.term_for_challenges
        )

    postPredictedGrade = (assignment_id,value)->
      $http.post('/assignments/' + assignment_id + '/grades/predict_score', predicted_score: value).success(
        (data)->
          console.log(data);
        ).error(
        (data)->
          console.log(data);
        )

    postPredictedChallenge = (challenge_id,value)->
      $http.post('/challenges/' + challenge_id + '/predict_points', points_earned: value).success(
        (data)->
          console.log(data);
        ).error(
        (data)->
          console.log(data);
        )

    postPredictedBadge = (badge_id,value)->

      $http.post('/badges/' + badge_id + '/predict_times_earned', times_earned: value).success(
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
        getChallenges: getChallenges
        postPredictedGrade: postPredictedGrade
        postPredictedBadge: postPredictedBadge
        postPredictedChallenge: postPredictedChallenge
        assignments: assignments
        assignmentTypes: assignmentTypes
        gradeLevels: gradeLevels
        badges: badges
        challenges: challenges
        termFor: termFor
        icons: icons
    }
]
