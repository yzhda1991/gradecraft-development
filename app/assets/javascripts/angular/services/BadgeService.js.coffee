# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'BadgeService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', ($http, GradeCraftAPI, GradeCraftPredictionAPI) ->

  badges = []
  earnedBadges = []
  update = {}

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  badgesPredictedPoints = ()->
    total = 0
    _.each(badges,(badge)->
        total += badge.prediction.predicted_times_earned * badge.full_points
      )
    total

  studentEarnedBadgeForGrade = (studentId, badgeId, gradeId)->
    _.find(earnedBadges,{ badge_id: parseInt(badgeId), grade_id: parseInt(gradeId) })

  #------ API Calls -----------------------------------------------------------#

  # GET index list of badges
  # includes a student's predictions
  getBadges = (studentId)->
    $http.get(GradeCraftAPI.uriPrefix(studentId) + 'badges').success( (response)->
      GradeCraftAPI.loadMany(badges, response, {"include" : ['prediction']})
      _.each(badges, (badge)->
        # add earned badge count for generic predictor
        badge.earned_badge_count = 0 if !badge.earned_badge_count
        # add null prediction when JSON contains no prediction
        badge.prediction = {predicted_times_earned: badge.earned_badge_count} if !badge.prediction
      )
      GradeCraftAPI.loadFromIncluded(earnedBadges,"earned_badges", response)
      GradeCraftAPI.setTermFor("badges", response.meta.term_for_badges)
      GradeCraftAPI.setTermFor("badge", response.meta.term_for_badge)
      update.predictions = response.meta.allow_updates
    )

  # PUT a badge prediction
  postPredictedBadge = (badge)->
    if update.predictions
      requestParams = {
        "predicted_earned_badge": {
          "badge_id": badge.id,
          "predicted_times_earned": badge.prediction.predicted_times_earned
        }}
      if badge.prediction.id
        GradeCraftPredictionAPI.updatePrediction(badge, '/api/predicted_earned_badges/' + badge.prediction.id, requestParams)
      else
        GradeCraftPredictionAPI.createPrediction(badge, '/api/predicted_earned_badges/', requestParams)

  # currently creates explictly for a student and a grade
  createEarnedBadge = (badgeId, studentId, gradeId)->
    requestParams = {
      "student_id": studentId,
      "badge_id": badgeId,
      "grade_id": gradeId
    }

    $http.post('/api/earned_badges/', requestParams).then(
      (response)-> # success
        if response.status == 201
          GradeCraftAPI.addItem(earnedBadges, "earned_badges", response.data)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  deleteEarnedBadge = (earnedBadge)->
    $http.delete("/api/earned_badges/#{earnedBadge.id}").then(
      (response)-> # success
        if response.status == 200
          GradeCraftAPI.deleteItem(earnedBadges, earnedBadge)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  return {
      termFor: termFor
      getBadges: getBadges
      badgesPredictedPoints: badgesPredictedPoints
      postPredictedBadge: postPredictedBadge
      createEarnedBadge: createEarnedBadge
      deleteEarnedBadge: deleteEarnedBadge
      studentEarnedBadgeForGrade: studentEarnedBadgeForGrade
      badges: badges
      earnedBadges: earnedBadges
  }
]
