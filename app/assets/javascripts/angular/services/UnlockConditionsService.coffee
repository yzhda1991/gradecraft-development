@gradecraft.factory 'UnlockConditionService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  unlockConditions = []

  getUnlockConditions = (conditionId, conditionType) ->
    $http.get("/api/#{conditionType.toLowerCase()}s/#{conditionId}/unlock_conditions").then((response) ->
      GradeCraftAPI.loadMany(unlockConditions, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  {
    unlockConditions: unlockConditions
    getUnlockConditions: getUnlockConditions
  }
]
