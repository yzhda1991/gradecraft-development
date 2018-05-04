@gradecraft.factory "GradingStatusSubmissionsService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  ungraded = []
  # _loadingProgress = "Loading submissions..."

  # loadingProgress = (progress) -> if angular.isDefined(progress) then _loadingProgress = progress else _loadingProgress

  getUngraded = () ->
    $http.get("/api/grading_status/submissions/ungraded").then(
      (response) ->
        GradeCraftAPI.loadMany(ungraded, response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  termFor = (term) -> GradeCraftAPI.termFor(term)

  {
    ungraded: ungraded
    getUngraded: getUngraded
    termFor: termFor
  }
]
