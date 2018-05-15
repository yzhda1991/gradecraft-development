@gradecraft.factory "GradingStatusService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  ungradedSubmissions = []
  inProgressGrades = []

  clearData = () ->
    ungradedSubmissions.length = 0
    inProgressGrades.length = 0

  getUngradedSubmissions = () ->
    $http.get("/api/grading_status/submissions/ungraded").then(
      (response) ->
        GradeCraftAPI.loadMany(ungradedSubmissions, response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getInProgressGrades = (clear=false) ->
    clearData() if clear is true

    $http.get("/api/grading_status/grades/in_progress").then(
      (response) ->
        GradeCraftAPI.loadMany(inProgressGrades, response.data)
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
