@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    termFor = {
        assignmentType: ""
        assignment: ""
        pass: ""
        fail: ""
        badges: ""
        challenges: ""
        weights: ""
    }
    gradeLevels = {}
    assignments = []
    assignmentTypes = []
    update = {}
    weights = {
      unusedWeights: ()->
        return 0
    }
    badges = []
    challenges = []
    icons = ["is_required", "is_late", "has_closed", "has_info", "has_rubric", "accepts_submissions", "is_locked", "has_been_unlocked", "is_a_condition", "is_earned_by_group"]
    unusedWeights = null

    getGradeLevels = ()->
      $http.get("predictor_grade_levels").success((data)->
        angular.copy(data,gradeLevels)
      )

    getAssignmentTypes = ()->
      $http.get("predictor_assignment_types").success((data)->
        angular.copy(data.assignment_types, assignmentTypes)
        termFor.assignmentType = data.term_for_assignment_type
      )


    getAssignmentTypeWeights = ()->
      $http.get("predictor_weights").success( (data)->
        angular.copy(data.weights, weights)
        termFor.weights = data.term_for_weights
        weights.open = !weights.close_at || Date.parse(weights.close_at) >= Date.now()
        update.weights = data.update_weights
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
          weights.max_types_weighted - types
        )

    getAssignments = ()->
      $http.get("predictor_assignments").success( (data)->
        angular.copy(data.assignments,assignments)
        termFor.assignment = data.term_for_assignment
        termFor.pass = data.term_for_pass
        termFor.fail = data.term_for_fail
        update.assignments = data.update_assignments
      )

    getBadges = ()->
      $http.get('predictor_badges').success( (data)->
          angular.copy(data.badges,badges)
          termFor.badges = data.term_for_badges
          termFor.badge = data.term_for_badge
          update.badges = data.update_badges
        )

    getChallenges = ()->
      $http.get('predictor_challenges').success( (data)->
          angular.copy(data.challenges,challenges)
          termFor.challenges = data.term_for_challenges
          update.challenges = data.update_challenges
        )

    postPredictedGrade = (assignment_id,value)->
      if update.assignments
        $http.post('/assignments/' + assignment_id + '/grades/predict_score', predicted_score: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    postPredictedChallenge = (challenge_id,value)->
      if update.challenges
        $http.post('/challenges/' + challenge_id + '/predict_points', points_earned: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    postPredictedBadge = (badge_id,value)->
      if update.badges
        $http.post('/badges/' + badge_id + '/predict_times_earned', times_earned: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    postAssignmentTypeWeight = (assignmentType_id,value)->
      if update.weights
        $http.post('/assignment_type_weight', id: assignmentType_id, weight: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    return {
        getGradeLevels: getGradeLevels
        getAssignmentTypes: getAssignmentTypes
        getAssignmentTypeWeights: getAssignmentTypeWeights
        getAssignments: getAssignments
        getBadges: getBadges
        getChallenges: getChallenges
        postPredictedGrade: postPredictedGrade
        postPredictedBadge: postPredictedBadge
        postPredictedChallenge: postPredictedChallenge
        postAssignmentTypeWeight: postAssignmentTypeWeight
        assignments: assignments
        assignmentTypes: assignmentTypes
        weights: weights
        gradeLevels: gradeLevels
        badges: badges
        challenges: challenges
        termFor: termFor
        icons: icons
    }
]
