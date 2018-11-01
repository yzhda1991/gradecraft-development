gradecraft.factory "StudentService", ["GradeCraftAPI", "CourseMembershipService", "orderByFilter", "$http", "$q",
  (GradeCraftAPI, CourseMembershipService, orderBy, $http, $q) ->
    students = []
    teams = []  # student association
    earnedBadges = [] # student association

    _studentIds = []  # for batch loading
    _loadingProgress = undefined

    loadingProgress = (progress) -> if angular.isDefined(progress) then _loadingProgress = progress else _loadingProgress

    clearStudents = () -> students.length = 0

    termFor = (term) -> GradeCraftAPI.termFor(term)

    # fetch student data in batches
    getBatchedForAssignment = (assignmentId, teamId=null, batchSize=25) ->
      getForAssignment(assignmentId, null, true).then(() ->
        return unless _studentIds.length
        loadingProgress("Loading students...")

        promises = []
        _.each(_.chunk(_studentIds, batchSize), (batch) ->
          promises.push(getForAssignment(assignmentId, teamId, false, batch...))
        )

        $q.all(promises).then(() ->
          _studentIds.length = 0
          loadingProgress(null)
        )
      )

    # assignmentId: the id of the assignment to fetch student data for
    # fetchIds: false to fetch student data; otherwise, true to fetch only their ids
    # studentIds (optional): the student ids to fetch data for
    #
    # Specify only the assignmentId to fetch all students at once
    getForAssignment = (assignmentId, teamId=null, fetchIds=false, studentIds...) ->
      $http.get("/api/assignments/#{assignmentId}/students", { params: { team_id: teamId, fetch_ids: _booleanToInt(fetchIds), "student_ids[]": studentIds } }).then(
        (response) ->
          if fetchIds is true
            angular.copy(response.data.student_ids, _studentIds)
          else
            GradeCraftAPI.loadMany(students, response.data)
            GradeCraftAPI.setTermFor("student", response.data.meta.term_for_student)
            GradeCraftAPI.setTermFor("weight", response.data.meta.term_for_weight)
            loadingProgress("Loaded #{students.length}/#{_studentIds.length} students")
          GradeCraftAPI.logResponse(response.data)
        , (response) ->
          GradeCraftAPI.logResponse(response.data)
      )

    getBatchedForCourse = (courseId, batchSize=50) ->
      getForCourse(courseId, true).then(() ->
        return unless _studentIds.length
        loadingProgress("Loading students...")

        promises = []
        _.each(_.chunk(_studentIds, batchSize), (batch) ->
          promises.push(getForCourse(courseId, false, batch...))
        )

        $q.all(promises).then(() ->
          _studentIds.length = 0
          loadingProgress(null)
        )
      )

    getForCourse = (courseId, fetchIds=false, studentIds...) ->
      $http.get("/api/courses/#{courseId}/students", { params: { fetch_ids: _booleanToInt(fetchIds), "student_ids[]": studentIds } }).then(
        (response) ->
          if fetchIds is true
            angular.copy(response.data.student_ids, _studentIds)
          else
            GradeCraftAPI.loadMany(students, response.data)
            GradeCraftAPI.loadFromIncluded(earnedBadges, "earned_badges", response.data)
            GradeCraftAPI.loadFromIncluded(teams, "teams", response.data)
            recalculateRanks(students)
            GradeCraftAPI.setTermFor("student", response.data.meta.student)
            GradeCraftAPI.setTermFor("students", response.data.meta.students)
            loadingProgress("Loaded #{students.length}/#{_studentIds.length} students")
            GradeCraftAPI.logResponse(response.data)
        , (response) ->
          GradeCraftAPI.logResponse(response.data)
      )

    activate = (student, notify=true) ->
      $http.put("/users/#{student.id}/manually_activate").then(
        (response) ->
          student.activated = true
          alert("#{student.name} was successfully activated") if notify is true
          GradeCraftAPI.logResponse(response.data)
        , (response) ->
          GradeCraftAPI.logResponse(response.data)
      )

    flag = (student) ->
      $http.post("/users/#{student.id}/flag").then(
        (response) ->
          student.flagged = response.data.flagged
          GradeCraftAPI.logResponse(response.data)
        , (response) ->
          alert("An error occurred while attempting to flag the student")
          GradeCraftAPI.logResponse(response.data)
      )

    earnedBadgesForStudent = (studentId) -> _.filter(earnedBadges, { student_id: studentId })

    team = (teamId) -> _.find(teams, { id: teamId })

    #
    # Course membership-related methods, passed through to CourseMembershipService
    #

    toggleActivation = (courseMembershipId, student) -> CourseMembershipService.toggleActivation(courseMembershipId, student)

    deleteFromCourse = (courseMembershipId, student) ->
      CourseMembershipService.destroy(courseMembershipId).then(
        (success) ->
          students.splice(students.indexOf(student) , 1)
          alert("Successfully deleted #{student.name} from the course")
        , (failure) -> alert("Failed to delete #{student.name} from course")
      )

    recalculateRanks = (students) ->
      return unless students.length
      index = 0
      angular.copy(orderBy(students, ["score", "last_name"], true), students)
      setRank = (rank, student) -> student.rank = rank
      setRank(index += 1, student) for student in students when not student.auditing and student.activated_for_course

    # used for GET params: easier to compare a number versus a stringified boolean on the server side
    _booleanToInt = (boolean) -> if boolean is true then 1 else 0

    {
      students: students
      loadingProgress: loadingProgress
      clearStudents: clearStudents
      termFor: termFor
      getBatchedForAssignment: getBatchedForAssignment
      getForAssignment: getForAssignment
      getBatchedForCourse: getBatchedForCourse
      getForCourse: getForCourse
      earnedBadgesForStudent: earnedBadgesForStudent
      recalculateRanks: recalculateRanks

      activate: activate
      flag: flag
      team: team

      toggleActivation: toggleActivation
      deleteFromCourse: deleteFromCourse
    }
]
