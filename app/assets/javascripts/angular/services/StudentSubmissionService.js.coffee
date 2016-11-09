@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  saveDraftSubmission = (assignmentId, submission) ->
    if submission.id? then updateDraftSubmission(assignmentId, submission) else createDraftSubmission(assignmentId, submission)

  getDraftSubmission = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/submissions").then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        response.data.submission
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
        response.data.submission
    )

  createDraftSubmission = (assignmentId, submission) ->
    $http.post("/api/assignments/#{assignmentId}/submissions", submission).then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        response.data.submission
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
        null
    )

  updateDraftSubmission = (assignmentId, submission) ->
    $http.put("/api/assignments/#{assignmentId}/submissions/#{submission.id}", submission).then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
        response.data.submission
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
        submission
    )

  return {
    getDraftSubmission: getDraftSubmission
    saveDraftSubmission: saveDraftSubmission
  }
]
