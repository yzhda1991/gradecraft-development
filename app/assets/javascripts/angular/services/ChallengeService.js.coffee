# Manages state of Challenges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'ChallengeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  challenges = []
  update = {}

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  # Total points possible to earn from challenges
  challengesFullPoints = ()->
    total = 0
    _.each(challenges, (challenge)->
      total += challenge.full_points
      )
    total

  # Total points predicted for challenges
  challengesPredictedPoints = ()->
    total = 0
    _.each(challenges, (challenge)->
        if challenge.grade.score > 0
          total += challenge.grade.score
        else
          total += challenge.prediction.predicted_points
      )
    total


  #------ API Calls -----------------------------------------------------------#

  # GET index list of challenges including a student's grades and predictions
  getChallenges = ()->
    $http.get('/api/predicted_earned_challenges').success( (res)->
      GradeCraftAPI.loadMany(challenges,res)
      GradeCraftAPI.setTermFor("challenges", res.meta.term_for_challenges)
      update.challenges = res.meta.update_predictions
    )

  # PUT a challenge prediction
  postPredictedChallenge = (challenge)->
    if update.challenges
      $http.put(
        '/api/predicted_earned_challenges/' + challenge.prediction.id, predicted_points: challenge.prediction.predicted_points
        ).success(
          (data)->
            console.log(data);
        ).error(
          (data)->
            console.log(data);
        )

  return {
      termFor: termFor
      challengesFullPoints: challengesFullPoints
      challengesPredictedPoints: challengesPredictedPoints
      getChallenges: getChallenges
      postPredictedChallenge: postPredictedChallenge
      challenges: challenges
  }
]
