@gradecraft.factory "GradingStatusService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  ungradedSubmissions = []
  inProgressGrades = []
  readyForReleaseGrades = []

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
    inProgressGrades.length = 0 if clear is true

    $http.get("/api/grading_status/grades/in_progress").then(
      (response) ->
        GradeCraftAPI.loadMany(inProgressGrades, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  getReadyForReleaseGrades = (clear=false) ->
    readyForReleaseGrades.length = 0 if clear is true

    $http.get("/api/grading_status/grades/ready_for_release").then(
      (response) ->
        GradeCraftAPI.loadMany(readyForReleaseGrades, response.data)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  termFor = (term) -> GradeCraftAPI.termFor(term)

  {
    ungradedSubmissions: ungradedSubmissions
    readyForReleaseGrades: readyForReleaseGrades
    inProgressGrades: inProgressGrades
    getUngradedSubmissions: getUngradedSubmissions
    getInProgressGrades: getInProgressGrades
    getReadyForReleaseGrades: getReadyForReleaseGrades
    termFor: termFor
  }
]
