# Manages course API calls and associated data
#
# Utilizes TableFilterService in the event that there is a need to filter or
# sort courses that are loaded via getBatchedCourses
@gradecraft.factory 'CourseService', ['TableFilterService', '$http', 'GradeCraftAPI', '$q',
  (TableFilterService, $http, GradeCraftAPI, $q) ->

    staff = []
    courses = []
    students = []
    courseCreation = {}
    _courseIds = []
    _loadingProgress = undefined

    filteredCourses = TableFilterService.filtered

    course = () -> courses[0]

    creationChecklist = () ->
      return [] if !courseCreation.checklist
      return courseCreation.checklist

    hasCourses = () -> _.some(courses)

    loadingProgress = (progress) -> if angular.isDefined(progress) then _loadingProgress = progress else _loadingProgress

    termFor = (article) -> GradeCraftAPI.termFor(article)

    #------ API Calls -----------------------------------------------------------#

    getCourse = (id) ->
      $http.get("/api/courses/#{id}").then(
        (response) ->
          GradeCraftAPI.addItem(courses, "courses", response.data)
          GradeCraftAPI.setTermFor("team", response.data.meta.term_for_team)
          GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

    getCourses = (fetchIds=false, courseIds...) ->
      fetch = if fetchIds is true then 1 else 0
      $http.get("/api/courses", { params: { fetch_ids: fetch, "course_ids[]": courseIds } }).then(
        (response) ->
          if fetchIds is true
            _courseIds = response.data.course_ids
          else
            GradeCraftAPI.loadMany(courses, response.data, { "include" : ["staff"] })
            GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
            GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
            GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignment)
            GradeCraftAPI.setTermFor("assignment_type", response.data.meta.term_for_assignment_type)
            loadingProgress("Loaded #{courses.length}/#{_courseIds.length} courses")
            GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

    # fetch courses in batches
    getBatchedCourses = (batchSize=50) ->
      _loadingProgress = "Loading courses..."
      getCourses(true).then(() ->
        return unless _courseIds.length

        promises = []
        _.each(_.chunk(_courseIds, batchSize), (batch) ->
          promises.push(getCourses(false, batch...))
        )

        $q.all(promises).then(() ->
          TableFilterService.original(courses)
          _courseIds.length = 0
          loadingProgress(null)
        )
      )

    getCourseCreation = () ->
      $http.get("/api/course_creation").then(
        (response) ->
          GradeCraftAPI.loadItem(courseCreation, "course_creation", response.data)
          GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignments)
          GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
          GradeCraftAPI.setTermFor("teams", response.data.meta.term_for_teams)
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

    # Get all students in the current course
    getStudents = () ->
      $http.get("/api/students").then(
        (response) ->
          angular.copy(response.data, students)
          GradeCraftAPI.logResponse(response.data)
        , (response) ->
          GradeCraftAPI.logResponse(response.data)
      )

    updateCourseCreationItem = (item) ->
      params = {"course_creation" : { "#{item.name}" : item.done }}
      $http.put("/api/course_creation", params).then(
        (response) ->
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

    {
      staff: staff
      course: course
      courses: courses
      students: students
      filteredCourses: filteredCourses
      loadingProgress: loadingProgress
      hasCourses: hasCourses
      termFor: termFor
      getCourse: getCourse
      getCourses: getCourses
      getBatchedCourses: getBatchedCourses
      getCourseCreation: getCourseCreation
      getStudents: getStudents
      updateCourseCreationItem: updateCourseCreationItem
      courseCreation: courseCreation
      creationChecklist: creationChecklist
    }
]
