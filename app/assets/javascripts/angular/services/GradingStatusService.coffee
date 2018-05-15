@gradecraft.factory "GradingStatusService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  ungradedSubmissions = []
  inProgressGrades = []
  # _loadingProgress = "Loading submissions..."

  # loadingProgress = (progress) -> if angular.isDefined(progress) then _loadingProgress = progress else _loadingProgress

  getUngradedSubmissions = () ->
    $http.get("/api/grading_status/submissions/ungraded").then(
      (response) ->
        GradeCraftAPI.loadMany(ungradedSubmissions, response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getInProgressGrades = () ->
    $http.get("/api/grading_status/grades/in_progress").then(
      (response) ->
        GradeCraftAPI.loadMany(inProgressGrades, response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  termFor = (term) -> GradeCraftAPI.termFor(term)

  {
    ungradedSubmissions: ungradedSubmissions
    inProgressGrades: inProgressGrades
    getUngradedSubmissions: getUngradedSubmissions
    getInProgressGrades: getInProgressGrades
    termFor: termFor
  }
]
