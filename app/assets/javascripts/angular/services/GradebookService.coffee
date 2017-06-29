@gradecraft.factory 'GradebookService', ['$http', 'GradeCraftAPI', '$q', ($http, GradeCraftAPI, $q) ->

  students = []
  assignments = []
  _studentIds = []

  # GET assignment names sorted by assignment type order, assignment order
  getAssignments = () ->
    $http.get("/api/gradebook/assignments").then(
      (response) ->
        GradeCraftAPI.loadMany(assignments, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        GradeCraftAPI.setTermFor("badge", response.data.meta.term_for_badge)
        GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
    )

  # GET students, optionally in batches
  # If the ids for all students in the current course cannot be retrieved first
  # for a batched request, it will fall back to fetching all students at once
  getStudents = (batchStudents=true, batchSize=25) ->
    if batchStudents is true
      _getStudentIds().then(
        (success) ->
          promises = []
          _.each(_.chunk(_studentIds, batchSize), (idBatch) ->
            promises.push(_getStudents(idBatch))
          )
          $q.all(promises)
        , (failure) ->
          console.error "An error occurred while attempting to fetch students by batch"
          _getStudents()  # fall back to fetching all of them
      )
    else
      _getStudents()

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  # GET the gradebook data for the students, optionally for a specific subset
  _getStudents = (studentIds=null) ->
    params = { "student_ids[]": studentIds }

    $http.get("/api/gradebook/students", params: params).then(
      (response) ->
        GradeCraftAPI.loadMany(students, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # GET all the ids for the students in the course for querying by batch
  _getStudentIds = () ->
    $http.get("/api/gradebook/student_ids").then(
      (response) ->
        angular.copy(response.data, _studentIds)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  {
    students: students
    assignments: assignments
    getAssignments: getAssignments
    getStudents: getStudents
    termFor: termFor
  }
]
