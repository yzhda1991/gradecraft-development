# Manages state of Challenges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'ChallengeService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', ($http, GradeCraftAPI, GradeCraftPredictionAPI) ->

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
    $http.get('/api/challenges').success( (response)->
      return unless response.meta.include_in_predictor
      GradeCraftAPI.loadMany(challenges,response, {"include" : ['prediction','grade']})
      _.each(challenges, (challenge)->
        # add null prediction and grades when JSON contains none
        challenge.prediction = { predicted_points: 0 } if !challenge.prediction
        challenge.grade = { score: null, final_points: null } if !challenge.grade
      )

      GradeCraftAPI.setTermFor("challenges", response.meta.term_for_challenges)
      update.challenges = response.meta.allow_updates
    )

  # PUT a challenge prediction
  postPredictedChallenge = (challenge)->
    if update.challenges
      requestParams = {
        "predicted_earned_challenge": {
          "challenge_id": challenge.id,
          "predicted_points": challenge.prediction.predicted_points
        }}
      if challenge.prediction.id
        GradeCraftPredictionAPI.updatePrediction(challenge, '/api/predicted_earned_challenges/' + challenge.prediction.id, requestParams)
      else
        GradeCraftPredictionAPI.createPrediction(challenge, '/api/predicted_earned_challenges/', requestParams)

  return {
      termFor: termFor
      challengesFullPoints: challengesFullPoints
      challengesPredictedPoints: challengesPredictedPoints
      getChallenges: getChallenges
      postPredictedChallenge: postPredictedChallenge
      challenges: challenges
  }
]
