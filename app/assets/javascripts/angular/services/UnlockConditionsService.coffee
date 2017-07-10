@gradecraft.factory 'UnlockConditionService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  unlockConditions = []
  assignments = []
  assignmentTypes = []
  badges = []

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  getUnlockConditions = (conditionId, conditionType) ->
    $http.get("/api/#{conditionType.toLowerCase()}s/#{conditionId}/unlock_conditions").then((response) ->
      GradeCraftAPI.loadMany(unlockConditions, response.data)
      angular.copy(response.data.meta.assignments, assignments)
      angular.copy(response.data.meta.assignment_types, assignmentTypes)
      angular.copy(response.data.meta.badges, badges)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  addCondition = ()->
    unlockConditions.push(
      "id": null,
      "unlockable_id": null,
      "unlockable_type": null,
      "condition_id": null,
      "condition_type": null,
      "condition_state": null,
      "condition_value": null
      "condition_date": null
    )

  removeCondition = (index)->
    # TODO: delete from server if it has an id
    unlockConditions.splice(index,1)

  {
    termFor: termFor
    assignments: assignments
    assignmentTypes: assignmentTypes
    badges: badges
    unlockConditions: unlockConditions
    getUnlockConditions: getUnlockConditions
    addCondition: addCondition
    removeCondition: removeCondition
  }
]
