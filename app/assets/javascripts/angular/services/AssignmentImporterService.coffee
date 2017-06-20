@gradecraft.factory 'AssignmentImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  assignmentRows = []
  successful = []
  unsuccessful = []

  postUpload = (importer_provider_id, formData) ->
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
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  postImportAssignments = (importer_provider_id) ->
    _clearArrays(successful, unsuccessful)
    params = { assignment_attributes: assignmentRows }

    $http.post("/api/assignments/importers/#{importer_provider_id}/import", assignments: params).then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        console.log "Successfully created some things"
      ,(response) ->
        GradeCraftAPI.logResponse(response)
        console.error "An error occurred"
    )

  # Converts a Ruby time as number of floating point seconds to a Javascript Time
  _parseDatesAsJavascript = () ->
    _.each(assignmentRows, (row) ->
      row.selected_due_date = new Date(row.formatted_due_date)
    )

  _clearArrays = (arrays...) ->
    _.each(arrays, (array) ->
      array.length = 0
    )

  {
    assignmentRows: assignmentRows
    postUpload: postUpload
    postImportAssignments: postImportAssignments
  }
]
