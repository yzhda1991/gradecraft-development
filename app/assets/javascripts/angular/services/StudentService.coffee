@gradecraft.factory 'StudentService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  students = []

  termFor = (term) -> GradeCraftAPI.termFor(term)

  getForAssignment = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/students").then(
      (response) ->
        GradeCraftAPI.loadMany(students, response.data)
        GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  {
    students: students
    termFor: termFor
    getForAssignment: getForAssignment
  }
]
