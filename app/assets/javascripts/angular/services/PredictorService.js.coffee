@gradecraft.factory 'PredictorService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

    update = GradeCraftAPI.update
    termFor = GradeCraftAPI.termFor

    gradeSchemeElements = []
    _totalPoints  = 0
    assignments = []
    badges = []
    challenges = []
    icons = [
      "has_info", "is_required", "is_rubric_graded","accepting_submissions",
      "has_submission", "has_threshold", "is_late", "closed_without_submission",
      "is_locked", "has_been_unlocked", "is_a_condition", "is_earned_by_group"
    ]

    totalPoints = ()->
      _totalPoints

    getGradeSchemeElements = ()->
      $http.get("/api/grade_scheme_elements").success((res)->
        _.each(res.data, (gse)->
          gradeSchemeElements.push(gse.attributes)
        )
        _totalPoints = res.meta.total_points
      )

    getAssignments = (studentId)->
      $http.get(GradeCraftAPI.uri_prefix(studentId) + 'predicted_earned_grades').success( (res)->
        _.each(res.data, (assignment)->
          assignments.push(assignment.attributes)
        )
        termFor.assignment = res.meta.term_for_assignment
        termFor.pass = res.meta.term_for_pass
        termFor.fail = res.meta.term_for_fail
        update.assignments = res.meta.update_assignments
      )

    getBadges = (studentId)->
      $http.get(GradeCraftAPI.uri_prefix(studentId) + 'predicted_earned_badges').success( (res)->
        _.each(res.data, (badge)->
          badges.push(badge.attributes)
        )
        termFor.badges = res.meta.term_for_badges
        termFor.badge = res.meta.term_for_badge
        update.badges = res.meta.update_badges
      )

    getChallenges = (studentId)->
      $http.get(GradeCraftAPI.uri_prefix(studentId) + 'predicted_earned_challenges').success( (res)->
        _.each(res.data, (challenge)->
          challenges.push(challenge.attributes)
        )
        termFor.challenges = res.meta.term_for_challenges
        update.challenges = res.meta.update_challenges
      )

    postPredictedGrade = (id, value)->
      if update.assignments
        $http.put('/api/predicted_earned_grades/' + id, predicted_points: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    postPredictedChallenge = (id, value)->
      if update.challenges
        $http.put('/api/predicted_earned_challenges/' + id, predicted_points: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    postPredictedBadge = (id, value)->
      if update.badges
        $http.put('/api/predicted_earned_badges/' + id, predicted_times_earned: value).success(
            (data)->
              console.log(data);
          ).error(
            (data)->
              console.log(data);
          )

    return {
        getGradeSchemeElements: getGradeSchemeElements
        getAssignments: getAssignments
        getBadges: getBadges
        getChallenges: getChallenges
        postPredictedGrade: postPredictedGrade
        postPredictedBadge: postPredictedBadge
        postPredictedChallenge: postPredictedChallenge
        assignments: assignments
        gradeSchemeElements: gradeSchemeElements
        totalPoints: totalPoints
        badges: badges
        challenges: challenges
        termFor: termFor
        icons: icons
    }
]
