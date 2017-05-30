@gradecraft.factory 'GradeImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grades = []
  hasError = false

  # Fetch grades by batch with a page number
  getGrades = (assignmentId, courseId, provider, assignmentIds, page = 1) ->
    $http.get("/api/assignments/#{assignmentId}/grades/importers/#{provider}/course/#{courseId}",
      params: _gradeParams(page, assignmentIds)).then(
        (response) ->
          GradeCraftAPI.addItems(grades, "imported_grade", response.data)
          GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
          GradeCraftAPI.setTermFor("provider_assignment_name", response.data.meta.term_for_provider_assignment)
          GradeCraftAPI.logResponse(response.data)
          getGrades(assignmentId, courseId, provider, assignmentIds, page + 1) if _hasNextPage(response)
        , (response) ->
          hasError = true
          window.location.replace("/auth/#{provider}") if response.status == 401
          GradeCraftAPI.logResponse(response.data)
    )

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  selectAllGrades = () ->
    _setGradesSelected(true)

  deselectAllGrades = () ->
    _setGradesSelected(false)

  checkHasError = () ->
    hasError

  _hasNextPage = (response) ->
    response.data.meta.has_next_page

  _setGradesSelected = (selected) ->
    _.each(grades, (grade) ->
      grade.selected_for_import = selected
      true  # if selected is false, this loop is broken without this line
    )

  _gradeParams = (page, assignmentIds) ->
    {
      page: page
      assignment_ids: assignmentIds
    }

  {
    grades: grades
    getGrades: getGrades
    termFor: termFor
    selectAllGrades: selectAllGrades
    deselectAllGrades: deselectAllGrades
    checkHasError: checkHasError
  }
]
