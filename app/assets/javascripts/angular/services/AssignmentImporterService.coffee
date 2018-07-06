@gradecraft.factory 'AssignmentImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  assignmentRows = []
  results = []

  postUpload = (importer_provider_id, formData) ->
    _clearArrays(assignmentRows, results)

    $http.post("/api/assignments/importers/#{importer_provider_id}/upload",
      formData, {
        transformRequest: angular.identity,
        headers: { 'Content-Type': undefined }
      }
    ).then(
      (response) ->
        GradeCraftAPI.loadMany(assignmentRows, response.data)
        _parseDatesAsJavascript()
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  postImportAssignments = (importer_provider_id) ->
    _clearArrays(results)
    params = { assignment_attributes: assignmentRows }

    $http.post("/api/assignments/importers/#{importer_provider_id}/import", assignments: params).then(
      (response) ->
        angular.copy(response.data, results)
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # Converts a Ruby time as number of floating point seconds to a Javascript Time
  _parseDatesAsJavascript = () ->
    _.each(assignmentRows, (row) ->
      row.selected_due_at = new Date(row.formatted_due_at) if row.formatted_due_at?
      row.selected_open_at = new Date(row.formatted_open_at) if row.formatted_open_at?
      row.selected_accepts_submissions_until = new Date(row.formatted_accepts_submissions_until) if row.formatted_accepts_submissions_until?
      row.hasInvalidDueDate = !row.selected_due_at?
      true
    )

  _clearArrays = (arrays...) ->
    _.each(arrays, (array) ->
      array.length = 0
    )

  {
    assignmentRows: assignmentRows
    results: results
    postUpload: postUpload
    postImportAssignments: postImportAssignments
  }
]
