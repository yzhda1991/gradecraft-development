@gradecraft.factory 'StudentService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  students = []
  _loading = true

  isLoading = (loading) -> if angular.isDefined(loading) then _loading = loading else _loading

  termFor = (term) -> GradeCraftAPI.termFor(term)

  getForAssignment = (assignmentId) ->
    students.length = 0
    $http.get("/api/assignments/#{assignmentId}/students").then(
      (response) ->
        GradeCraftAPI.loadMany(students, response.data)
        GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
        isLoading(false)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  {
    students: students
    isLoading: isLoading
    termFor: termFor
    getForAssignment: getForAssignment
  }
]
