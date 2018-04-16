@gradecraft.factory 'StudentService', ['GradeCraftAPI', '$http', '$q', (GradeCraftAPI, $http, $q) ->

  students = []
  _studentIds = []  # for batch loading
  _loading = true
  _loadingProgress = "Loading students..."

  isLoading = (loading) -> if angular.isDefined(loading) then _loading = loading else _loading

  loadingProgress = (progress) -> if angular.isDefined(progress) then _loadingProgress = progress else _loadingProgress

  clearStudents = () -> students.length = 0

  termFor = (term) -> GradeCraftAPI.termFor(term)

  # fetch student data in batches
  getBatchedForAssignment = (assignmentId, teamId=null, batchSize=25) ->
    getForAssignment(assignmentId, null, true).then(() ->
      return unless _studentIds.length

      promises = []
      _.each(_.chunk(_studentIds, batchSize), (batch) ->
        promises.push(getForAssignment(assignmentId, teamId, false, batch...))
      )

      $q.all(promises).then(() ->
        _studentIds.length = 0
        isLoading(false)
        loadingProgress("Loading students...")
      )
    )

  # assignmentId: the id of the assignment to fetch student data for
  # fetchIds: false to fetch student data; otherwise, true to fetch only their ids
  # studentIds (optional): the student ids to fetch data for
  #
  # Specify only the assignmentId to fetch all students at once
  getForAssignment = (assignmentId, teamId=null, fetchIds=false, studentIds...) ->
    fetch = if fetchIds is true then 1 else 0 # easier to compare a number over a boolean on the server side
    $http.get("/api/assignments/#{assignmentId}/students", { params: { team_id: teamId, fetch_ids: fetch, "student_ids[]": studentIds } }).then(
      (response) ->
        if fetchIds is true
          _studentIds = response.data.student_ids
        else
          GradeCraftAPI.loadMany(students, response.data)
          GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
          loadingProgress("Loaded #{students.length}/#{_studentIds.length} students")
          isLoading(false) if !studentIds.length
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  {
    students: students
    isLoading: isLoading
    loadingProgress: loadingProgress
    clearStudents: clearStudents
    termFor: termFor
    getBatchedForAssignment: getBatchedForAssignment
    getForAssignment: getForAssignment
  }
]
