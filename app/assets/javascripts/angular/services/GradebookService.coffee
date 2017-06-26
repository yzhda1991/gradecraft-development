@gradecraft.factory 'GradebookService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grades = []
  assignments = []
  _gradeIds = []

  # Get assignment names sorted by assignment type order, assignment order
  getAssignments = () ->
    $http.get("/api/gradebook/assignments").then(
      (response) ->
        GradeCraftAPI.loadMany(assignments, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # Get grades, optionally in batches
  getGrades = (batchGrades=true, batchSize=50) ->
    if batchGrades is true
      _getStudentIds().then(
        (success) ->
          _.each(_.chunk(_gradeIds, batchSize), (idBatch) ->
            _getGrades(idBatch)
          )
        , (failure) ->
          console.error "An error occurred while attempting to fetch grades"
          # TODO: Raise error?
      )
    else
      _getGrades()


  _getGrades = (gradeIds=null) ->
    params = { "grade_ids[]": gradeIds }

    $http.get("/api/gradebook/grades", params: params).then(
      (response) ->
        GradeCraftAPI.loadMany(grades, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  _getStudentIds = () ->
    $http.get("/api/gradebook/grade_ids").then(
      (response) ->
        angular.copy(response.data, _gradeIds)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  {
    grades: grades
    assignments: assignments
    getAssignments: getAssignments
    getGrades: getGrades
  }
]
