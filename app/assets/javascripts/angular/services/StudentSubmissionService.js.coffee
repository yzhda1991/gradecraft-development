@gradecraft.factory 'StudentSubmissionService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  submission = {}

  getSubmission = () ->
    submission

  setSubmission = (newSubmission) ->
    angular.copy(newSubmission, submission)

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
    saveDraftSubmission: saveDraftSubmission
  }
]
