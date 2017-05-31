@gradecraft.factory 'AssignmentGradesService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grades = []
  assignment = {}

  getAssignmentWithGrades = (id, teamId=null) ->
    $http.get("/api/assignments/#{id}/grades", { params: { team_id: teamId } }).then(
      (response) ->
        _clearGrades()
        GradeCraftAPI.loadItem(assignment, "assignment", response.data)
        GradeCraftAPI.loadFromIncluded(grades, "grade", response.data)
        GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
        GradeCraftAPI.logResponse(response)
      (response) ->
        GradeCraftAPI.logResponse(response)
    )

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  _clearGrades = () ->
    grades.length = 0

  {
    grades: grades
    assignment: assignment
    getAssignmentWithGrades: getAssignmentWithGrades
    termFor: termFor
  }
]
