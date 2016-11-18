@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  submission = null

  setSubmission = (newSubmission) ->
    submission = newSubmission

  getSubmission = () ->
    submission

  saveDraftSubmission = (assignmentId) ->
    debugger
    if submission.id? then updateDraftSubmission(assignmentId) else createDraftSubmission(assignmentId)

  getDraftSubmission = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/submissions").then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        setSubmission(response.data.submission)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  createDraftSubmission = (assignmentId) ->
    $http.post("/api/assignments/#{assignmentId}/submissions", submission).then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        setSubmission(response.data.submission)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  updateDraftSubmission = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/submissions/#{submission.id}", submission).then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        setSubmission(response.data.submission)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  return {
    getSubmission: getSubmission
    setSubmission: setSubmission
    getDraftSubmission: getDraftSubmission
    saveDraftSubmission: saveDraftSubmission
  }
]
