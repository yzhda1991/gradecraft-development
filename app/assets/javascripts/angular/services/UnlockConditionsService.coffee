@gradecraft.factory 'UnlockConditionService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  unlockConditions = []
  assignments = []

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  getUnlockConditions = (conditionId, conditionType) ->
    $http.get("/api/#{conditionType.toLowerCase()}s/#{conditionId}/unlock_conditions").then((response) ->
      GradeCraftAPI.loadMany(unlockConditions, response.data)
      angular.copy(response.data.meta.assignments, assignments)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  {
    termFor: termFor
    assignments: assignments
    unlockConditions: unlockConditions
    getUnlockConditions: getUnlockConditions
  }
]
