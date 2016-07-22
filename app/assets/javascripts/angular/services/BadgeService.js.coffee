# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'BadgeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  badges = []
  update = {}

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  badgesPredictedPoints = ()->
    total = 0
    _.each(badges,(badge)->
        total += badge.prediction.predicted_times_earned * badge.full_points
      )
    total

  #------ API Calls -----------------------------------------------------------#

  # GET index list of badges including a student's earned and predictions
  getBadges = (studentId)->
    $http.get(GradeCraftAPI.uriPrefix(studentId) + 'predicted_earned_badges').success( (res)->
      GradeCraftAPI.loadMany(badges,res)
      GradeCraftAPI.setTermFor("badges", res.meta.term_for_badges)
      GradeCraftAPI.setTermFor("badge", res.meta.term_for_badge)
      update.badges = res.meta.update_badges
    )

  # PUT a badge prediction
  postPredictedBadge = (badge)->
    if update.badges
      $http.put(
          '/api/predicted_earned_badges/' + badge.prediction.id, predicted_times_earned: badge.prediction.predicted_times_earned
        ).success(
          (data)->
            console.log(data);
        ).error(
          (data)->
            console.log(data);
        )

  return {
      termFor: termFor
      getBadges: getBadges
      badgesPredictedPoints: badgesPredictedPoints
      postPredictedBadge: postPredictedBadge
      badges: badges
  }
]
