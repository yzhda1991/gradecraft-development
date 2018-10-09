@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', 'DebounceQueue', '$http', (GradeCraftAPI, DebounceQueue, $http) ->

  self = this
  submission = {}

  queueSaveDraftSubmission = (assignmentId, immediate=false) ->
    delay = if immediate then 0 else null

    # cancel update if the student has cleared out the text_comment_draft
    unless submission.text_comment_draft
      DebounceQueue.cancelEvent("submissions", assignmentId)
      return

    # using assignmentId for queue id since we are not assured to have a submission.id
    DebounceQueue.addEvent("submissions", assignmentId, saveDraftSubmission, [assignmentId], delay)

  saveDraftSubmission = (assignmentId) ->
    if submission.id? then updateDraftSubmission(assignmentId) else createDraftSubmission(assignmentId)

  getDraftSubmission = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/submissions").then(
      (response) ->
        if response.data.data?  # if no submission is found, data is null
          GradeCraftAPI.loadItem(submission, "submission", response.data)
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  createDraftSubmission = (assignmentId) ->
    $http.post("/api/assignments/#{assignmentId}/submissions", submission).then(
      (response) ->
        GradeCraftAPI.loadItem(submission, "submission", response.data)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  updateDraftSubmission = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/submissions/#{submission.id}", submission).then(
      (response) ->
        GradeCraftAPI.loadItem(submission, "submission", response.data)
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
