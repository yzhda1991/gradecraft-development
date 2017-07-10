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

  # We need to remove all other fields when the
  # condition type is changed, to avoid invalid
  # condition configuration
  changeConditionType = (condition)->
    condition.condition_id = null
    condition.condition_state = null
    condition.condition_value = null
    condition.condition_date = null

  conditionIsValid = (condition)->
    return true if condition.condition_id && condition.condition_type && condition.condition_state
    return false

  {
    termFor: termFor
    assignments: assignments
    assignmentTypes: assignmentTypes
    badges: badges
    unlockConditions: unlockConditions
    getUnlockConditions: getUnlockConditions
    addCondition: addCondition
    removeCondition: removeCondition
    changeConditionType: changeConditionType
    conditionIsValid: conditionIsValid
  }
]
