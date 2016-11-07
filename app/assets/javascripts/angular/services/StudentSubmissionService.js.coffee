@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  autosaved_submission = null

  saveSubmission = (submission) ->
    autosaved_submission ?= submission
    promise = if autosaved_submission? && autosaved_submission.id? then updateDraftSubmission() else createDraftSubmission();
    promise.success(
      (response) ->
        autosaved_submission = response.submission
        GradeCraftAPI.logResponse(response)
    ).error(
      (response) ->
        GradeCraftAPI.logResponse(response)
    )

  createDraftSubmission = () ->
    return $http.post("/api/assignments/#{autosaved_submission.assignment_id}/submissions",
      { submission: autosaved_submission }
    )

  updateDraftSubmission = () ->
    return $http.put("/api/assignments/#{autosaved_submission.assignment_id}/submissions/#{autosaved_submission.id}",
      { submission: autosaved_submission }
    )

  return {
    saveSubmission: saveSubmission
  }
]
