# Manages state of Challenges including API calls.
# Can be used independently, or via another service (see PredictorService)

gradecraft.factory 'ChallengeService', ['$http', 'GradeCraftAPI', 'GradeCraftPredictionAPI', ($http, GradeCraftAPI, GradeCraftPredictionAPI) ->

  challenges = []
  update = {}
  addScoreToStudent = false

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  includeInPredictor = ()->
    challenges.length > 1 && addScoreToStudent

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
          total += challenge.prediction.predicted_points || 0
      )
    total


  #------ API Calls -----------------------------------------------------------#

  # GET index list of challenges including a student's grades and predictions
  getChallenges = ()->
    $http.get('/api/challenges').then(
      (response)->
        GradeCraftAPI.loadMany(challenges,response.data, {"include" : ['prediction','grade']})
        _.each(challenges, (challenge)->
          # add null prediction and grades when JSON contains none
          challenge.prediction = { predicted_points: 0 } if !challenge.prediction
          challenge.grade = { score: null, final_points: null } if !challenge.grade
        )

        GradeCraftAPI.setTermFor("challenges", response.data.meta.term_for_challenges)
        update.challenges = response.data.meta.allow_updates
        addScoreToStudent = response.data.meta.add_team_score_to_student
        GradeCraftAPI.logResponse(response)
      ,(response)->
        GradeCraftAPI.logResponse(response)
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
      includeInPredictor: includeInPredictor
  }
]
