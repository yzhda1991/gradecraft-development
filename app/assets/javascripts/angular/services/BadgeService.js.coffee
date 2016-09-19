# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'BadgeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

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

  studentEarnedBadgeForGrade = (studentId,badgeId,gradeId)->
    _.find(earnedBadges,{ badge_id: parseInt(badgeId), grade_id: parseInt(gradeId) })

  #------ API Calls -----------------------------------------------------------#

  # GET index list of badges
  # includes a student's earned badges and predictions
  getBadges = (studentId)->
    $http.get(GradeCraftAPI.uriPrefix(studentId) + 'badges').success( (response)->
      GradeCraftAPI.loadMany(badges, response, {"include" : ['prediction','earned_badge']})
      _.each(badges, (badge)->
        # add null prediction when JSON contains no prediction
        badge.prediction = {predicted_times_earned: 0} if !badge.prediction
      )
      GradeCraftAPI.loadFromIncluded(earnedBadges,"earned_badges", response)
      GradeCraftAPI.setTermFor("badges", response.meta.term_for_badges)
      GradeCraftAPI.setTermFor("badge", response.meta.term_for_badge)
      update.predictions = response.meta.update_predictions
    )

  # PUT a badge prediction
  postPredictedBadge = (badge)->
    if update.predictions
      $http.put(
          '/api/predicted_earned_badges/' + badge.prediction.id, predicted_times_earned: badge.prediction.predicted_times_earned
        ).success(
          (response)->
            console.log(response);
        ).error(
          (response)->
            console.log(response);
        )

  # currently creates explictly for a student and a grade
  createEarnedBadge = (studentId,badgeId,gradeId)->
    requestParams = {
      "student_id": studentId,
      "badge_id": badgeId,
      "grade_id": gradeId
    }

    # .success and .error are deprecated, only .then returns response
    # including headers and status code
    $http.post('/api/earned_badges/', requestParams).then(
      # success
      (response)->
        if response.status == 201
          GradeCraftAPI.addItem(earnedBadges, "earned_badges", response.data)

          # TODO:(UX) Visually we expect the earned badge count to update, but
          # this doesn't match the logic for this count in ruby
          # (grade has not been released!)
          _.find(badges,{id: response.data.data.attributes.badge_id}).earned_badge_count++

        GradeCraftAPI.logResponse(response)

      # error
      ,(response)->
        GradeCraftAPI.logResponse(response)
    )

  deleteEarnedBadge = (earnedBadge)->
    $http.delete("/api/earned_badges/#{earnedBadge.id}").then(
      # success
      (response)->
        if response.status == 200
          # TODO:(UX) see above
          _.find(badges,{id: earnedBadge.badge_id}).earned_badge_count--
          GradeCraftAPI.deleteItem(earnedBadges, earnedBadge)

        GradeCraftAPI.logResponse(response)

      # error
      ,(response)->
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
