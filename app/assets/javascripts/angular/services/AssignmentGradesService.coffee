@gradecraft.factory 'AssignmentGradesService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grades = []
  groupGrades = []
  assignment = {}
  assignmentScoreLevels = []
  _selectedGradingStyle = ""

  getAssignmentWithGrades = (id, teamId=null) ->
    $http.get("/api/assignments/#{id}/grades", { params: { team_id: teamId } }).then(
      (response) ->
        _clearArrays(grades, assignmentScoreLevels)
        GradeCraftAPI.loadItem(assignment, "assignment", response.data)
        GradeCraftAPI.loadFromIncluded(grades, "grade", response.data)
        GradeCraftAPI.loadFromIncluded(assignmentScoreLevels, "assignment_score_level", response.data)
        GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
        GradeCraftAPI.logResponse(response)
      (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getGroupAssignmentWithGrades = (id) ->
    $http.get("/api/assignments/#{id}/groups/grades").then(
      (response) ->
        GradeCraftAPI.loadItem(assignment, "assignment", response.data)
        GradeCraftAPI.loadFromIncluded(groupGrades, "group_grade", response.data)
        GradeCraftAPI.loadFromIncluded(assignmentScoreLevels, "assignment_score_level", response.data)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
      (response) ->
        GradeCraftAPI.logResponse(response)
    )

  selectedGradingStyle = (style) ->
    if angular.isDefined(style) then (_selectedGradingStyle = style) else _selectedGradingStyle

  setDefaultGradingStyle = () ->
    if assignment.pass_fail
      selectedGradingStyle("radio")
    else if assignment.has_levels
      if assignmentScoreLevels.length < 5 then selectedGradingStyle("radio") else selectedGradingStyle("select")
    else
      selectedGradingStyle("text")

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  _clearArrays = (arrays...) ->
    _.each(arrays, (array) ->
      array.length = 0
    )

  {
    grades: grades
    groupGrades: groupGrades
    assignment: assignment
    assignmentScoreLevels: assignmentScoreLevels
    selectedGradingStyle: selectedGradingStyle
    setDefaultGradingStyle: setDefaultGradingStyle
    assignmentScoreLevels: assignmentScoreLevels
    getAssignmentWithGrades: getAssignmentWithGrades
    getGroupAssignmentWithGrades: getGroupAssignmentWithGrades
    termFor: termFor
  }
]
