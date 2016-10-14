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
    $http.get('/api/challenges').success( (response)->
      GradeCraftAPI.loadMany(challenges,response, {"include" : ['prediction','grade']})
      _.each(challenges, (challenge)->
        # add null prediction and grades when JSON contains none
        challenge.prediction = { predicted_points: 0 } if !challenge.prediction
        challenge.grade = { score: null, final_points: null } if !challenge.grade
      )

      GradeCraftAPI.setTermFor("challenges", response.meta.term_for_challenges)
      update.challenges = response.meta.update_predictions
    )

  # PUT a challenge prediction
  postPredictedChallenge = (challenge)->
    if update.challenges
      if challenge.prediction.id
        updatePrediction(challenge)
      else
        createPrediction(challenge)

  createPrediction = (challenge)->
    requestParams = {
      "predicted_earned_challenge": {
        "challenge_id": challenge.id,
        "predicted_points": challenge.prediction.predicted_points
      }
    }

    $http.post('/api/predicted_earned_challenges/', requestParams).then(
      (response)-> # success
        if response.status == 201
          challenge.prediction = response.data.data.attributes
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  updatePrediction = (challenge)->
    $http.put(
      '/api/predicted_earned_challenges/' + challenge.prediction.id, predicted_points: challenge.prediction.predicted_points
    ).then((response)-> # success
              GradeCraftAPI.logResponse(response)
          ,(response)-> # error
              GradeCraftAPI.logResponse(response)
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
