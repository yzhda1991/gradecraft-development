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
    icons = ["has_info", "is_required", "is_rubric_graded", "accepting_submissions", "has_submission", "has_threshold", "is_late", "closed_without_submission", "is_locked", "has_been_unlocked", "is_a_condition", "is_earned_by_group"]
    unusedWeights = null

    uri_prefix = (student_id)->
      if student_id
        '/api/students/' + student_id + '/'
      else
        'api/'


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

    getBadges = (id)->
      $http.get(uri_prefix(id) + 'predicted_earned_badges').success( (res)->
          _.each(res.data, (badge)->
            badges.push(badge.attributes)
          )
          termFor.badges = res.meta.term_for_badges
          termFor.badge = res.meta.term_for_badge
          update.badges = res.meta.update_badges
        )

    getChallenges = ()->
      $http.get('predictor_challenges').success( (data)->
          angular.copy(data.challenges,challenges)
          termFor.challenges = data.term_for_challenges
          update.challenges = data.update_challenges
        )

    postPredictedGrade = (grade_id, value)->
      if update.assignments
        $http.post('/grades/' + grade_id + '/predict_score', predicted_score: value).success(
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

    postPredictedBadge = (id, value)->
      if update.badges
        $http.put('/api/predicted_earned_badges/' + id, times_earned: value).success(
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
