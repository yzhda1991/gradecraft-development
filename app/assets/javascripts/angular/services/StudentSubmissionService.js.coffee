@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', '$timeout', (GradeCraftAPI, $http, $timeout) ->

  self = this
  submission = {}
  saveTimeout = null

  getSubmission = () ->
    submission

  setSubmission = (newSubmission) ->
    angular.copy(newSubmission, submission)

  # Custom debounce method for autosaving submissions
  # Pass true for immediate to manually trigger save
  queueDraftSubmissionSave = (assignmentId, immediate = false) ->
    if immediate is true
      $timeout.cancel(self.saveTimeout)
      saveDraftSubmission(assignmentId)
    else
      $timeout.cancel(self.saveTimeout) if self.saveTimeout?
      self.saveTimeout = $timeout(() ->
        saveDraftSubmission(assignmentId)
      , 3500)

  saveDraftSubmission = (assignmentId) ->
    if getSubmission().id? then updateDraftSubmission(assignmentId) else createDraftSubmission(assignmentId)

  getDraftSubmission = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/submissions").then(
      (response) ->
        setSubmission(response.data.submission)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  createDraftSubmission = (assignmentId) ->
    $http.post("/api/assignments/#{assignmentId}/submissions", getSubmission()).then(
      (response) ->
        setSubmission(response.data.submission)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  updateDraftSubmission = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/submissions/#{getSubmission().id}", getSubmission()).then(
      (response) ->
        setSubmission(response.data.submission)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  return {
    getSubmission: getSubmission
    setSubmission: setSubmission
    getDraftSubmission: getDraftSubmission
    queueDraftSubmissionSave: queueDraftSubmissionSave
  }
]
