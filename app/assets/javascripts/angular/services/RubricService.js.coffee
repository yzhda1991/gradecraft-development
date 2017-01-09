
@gradecraft.factory 'RubricService', ['GradeCraftAPI', '$http', '$timeout', (GradeCraftAPI, $http, $timeout) ->

  rubric = {}
  criteria = []

  # for now, we get rubric url from assignment relationships
  getRubric = (rubricId)->
    $http.get("/api/rubrics/" + rubricId).then(
      (response) ->
        if response.data.data?  # if no rubric is found, data is null
          GradeCraftAPI.loadItem(rubric, "rubrics", response.data)
          GradeCraftAPI.loadFromIncluded(criteria, "criteria", response.data)
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  return {
    getRubric: getRubric
  }
]
