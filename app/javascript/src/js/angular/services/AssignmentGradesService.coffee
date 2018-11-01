gradecraft.factory 'AssignmentGradesService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  groups = []
  grades = []
  groupGrades = []
  assignment = {}
  assignmentScoreLevels = []
  _selectedGradingStyle = ""
  _loading = true

  isLoading = (loading) -> if angular.isDefined(loading) then _loading = loading else _loading

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

  # Fetches grades for groups with a very specific format intended for mass editing
  getGroupAssignmentWithMassEditGrades = (id) ->
    $http.get("/api/assignments/#{id}/groups/grades/mass_edit").then(
      (response) ->
        GradeCraftAPI.loadItem(assignment, "assignment", response.data)
        GradeCraftAPI.loadFromIncluded(groupGrades, "group_grade", response.data)
        GradeCraftAPI.loadFromIncluded(assignmentScoreLevels, "assignment_score_level", response.data)
        GradeCraftAPI.setTermFor("pass", response.data.meta.term_for_pass)
        GradeCraftAPI.setTermFor("fail", response.data.meta.term_for_fail)
      (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getGroupGradesForAssignment = (assignmentId, clearArrays=false) ->
    isLoading(true)

    if clearArrays is true
      groups.length = 0
      groupGrades.length = 0

    $http.get("/api/assignments/#{assignmentId}/groups/grades/").then(
      (response) ->
        GradeCraftAPI.loadMany(groups, response.data)
        GradeCraftAPI.loadFromIncluded(groupGrades, "grades", response.data)
        GradeCraftAPI.setTermFor("group", response.data.meta.group)
        GradeCraftAPI.setTermFor("groups", response.data.meta.groups)
        GradeCraftAPI.setTermFor("students", response.data.meta.term_for_students)
        isLoading(false)
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

  gradesForGroup = (group) ->
    studentIds = group.student_ids
    grades = []
    grades.push grade for grade in @groupGrades when grade.student_id in studentIds
    grades

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  _clearArrays = (arrays...) ->
    _.each(arrays, (array) ->
      array.length = 0
    )

  {
    groups: groups
    grades: grades
    isLoading: isLoading
    groupGrades: groupGrades
    assignment: assignment
    assignmentScoreLevels: assignmentScoreLevels
    selectedGradingStyle: selectedGradingStyle
    setDefaultGradingStyle: setDefaultGradingStyle
    gradesForGroup: gradesForGroup
    assignmentScoreLevels: assignmentScoreLevels
    getAssignmentWithGrades: getAssignmentWithGrades
    getGroupAssignmentWithMassEditGrades: getGroupAssignmentWithMassEditGrades
    getGroupGradesForAssignment: getGroupGradesForAssignment
    termFor: termFor
  }
]
