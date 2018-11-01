gradecraft.factory 'SubmissionService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->
  submissions = []

  getSubmissions = (assignment_ids=null, student_ids=null) ->
    $http.get("/api/submissions", { params: { "student_ids[]": student_ids, "assignment_ids[]": assignment_ids } }).then(
      (response) ->
        GradeCraftAPI.loadMany(submissions, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  forStudent = (student_id) -> _.filter(submissions, { student_id: student_id })

  forStudentAndAssignment = (student_id, assignment_id) ->
    _.find(submissions, { student_id: student_id, assignment_id: assignment_id })

  getSubmissions: getSubmissions
  forStudent: forStudent
  forStudentAndAssignment: forStudentAndAssignment
]
