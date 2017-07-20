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

  setBadgeIsUpdating = (badgeId, isUpdating=true)->
    badge = _.find(badges, {id: badgeId})
    badge.isUpdating = isUpdating

  #------ Badge Methods -------------------------------------------------------#

  # GET index list of badges
  # for students includes predictions
  # for faculty using student id, includes badge awards and availability
  getBadges = (studentId)->
    if studentId
      url = '/api/students/' + studentId + '/badges'
    else
      url = '/api/badges'
    $http.get(url).success( (response)->
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

  getBadge = (badgeId)->
    $http.get('/api/badges/' + badgeId).then(
      (response)->
        GradeCraftAPI.addItem(badges, "badges", response.data)
        GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
        GradeCraftAPI.setTermFor("badge", response.data.meta.term_for_badge)
        GradeCraftAPI.logResponse(response)
      ,(response)->
        GradeCraftAPI.logResponse(response)
    )

  #------ Badge Prediction Methods --------------------------------------------#

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

  #------ Earned Badge Methods ------------------------------------------------#

  # currently creates explictly for a student and a grade
  createEarnedBadge = (badgeId, studentId, gradeId)->
    setBadgeIsUpdating(badgeId)
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
        setBadgeIsUpdating(badgeId, false)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
        setBadgeIsUpdating(badgeId, false)
    )

  deleteEarnedBadge = (earnedBadge)->
    setBadgeIsUpdating(earnedBadge.badge_id)
    $http.delete("/api/earned_badges/#{earnedBadge.id}").then(
      (response)-> # success
        if response.status == 200
          setBadgeIsUpdating(earnedBadge.badge_id, false)
          GradeCraftAPI.deleteItem(earnedBadges, earnedBadge)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        setBadgeIsUpdating(earnedBadge.badge_id, false)
        GradeCraftAPI.logResponse(response)
    )

  return {
      termFor: termFor
      getBadges: getBadges
      getBadge: getBadge
      badges: badges

      badgesPredictedPoints: badgesPredictedPoints
      postPredictedBadge: postPredictedBadge

      earnedBadges: earnedBadges
      createEarnedBadge: createEarnedBadge
      deleteEarnedBadge: deleteEarnedBadge
      studentEarnedBadgeForGrade: studentEarnedBadgeForGrade
  }
]
