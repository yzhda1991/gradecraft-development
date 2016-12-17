@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', '$timeout', (GradeCraftAPI, $http, $timeout) ->

  self = this
  submission = {}
  saveTimeout = null

  # Custom debounce method for autosaving submissions
  # Pass true for immediate to manually trigger save
  queueSaveDraftSubmission = (assignmentId, immediate = false) ->
    unless submission.text_comment_draft
      $timeout.cancel(self.saveTimeout)
      return

    if immediate is true
      $timeout.cancel(self.saveTimeout)
      saveDraftSubmission(assignmentId)
    else
      $timeout.cancel(self.saveTimeout) if self.saveTimeout?
      self.saveTimeout = $timeout(() ->
        saveDraftSubmission(assignmentId)
      , 3500)

  saveDraftSubmission = (assignmentId) ->
    if submission.id? then updateDraftSubmission(assignmentId) else createDraftSubmission(assignmentId)

  getDraftSubmission = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/submissions").then(
      (response) ->
        if response.data.data?  # if no submission is found, data is null
          GradeCraftAPI.setItem(submission, "submission", response.data)
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  createDraftSubmission = (assignmentId) ->
    $http.post("/api/assignments/#{assignmentId}/submissions", submission).then(
      (response) ->
        GradeCraftAPI.setItem(submission, "submission", response.data)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  updateDraftSubmission = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/submissions/#{submission.id}", submission).then(
      (response) ->
        GradeCraftAPI.setItem(submission, "submission", response.data)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  return {
    submission: submission
    getDraftSubmission: getDraftSubmission
    queueSaveDraftSubmission: queueSaveDraftSubmission
  }
]
