@gradecraft.factory 'GradeImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grades = []
  hasError = false

  # Fetch grades by batch with a page number
  getGrades = (assignmentId, courseId, provider, assignmentIds, options={}) ->
    options.assignment_ids = assignmentIds
    $http.get("/api/assignments/#{assignmentId}/grades/importers/#{provider}/course/#{courseId}", params: options).then(
      (response) ->
        GradeCraftAPI.addItems(grades, "imported_grade", response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("provider_assignment_name", response.data.meta.term_for_provider_assignment)
        GradeCraftAPI.logResponse(response.data)
        getGrades(assignmentId, courseId, provider, assignmentIds, _nextPageParams(response)) if _nextPageParams(response)?
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

  _nextPageParams = (response) -> response.data.meta.page_params

  _setGradesSelected = (selected) ->
    _.each(grades, (grade) ->
      grade.selected_for_import = selected
      true  # if selected is false, this loop is broken without this line
    )

  {
    grades: grades
    getGrades: getGrades
    termFor: termFor
    selectAllGrades: selectAllGrades
    deselectAllGrades: deselectAllGrades
    checkHasError: checkHasError
  }
]
