# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'CourseService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  students = []
  courseCreation = {}

  creationChecklist = () ->
    return [] if !courseCreation.checklist
    return courseCreation.checklist

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  #------ API Calls -----------------------------------------------------------#

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
    students: students
    termFor: termFor
    getCourseCreation: getCourseCreation
    getStudents: getStudents
    updateCourseCreationItem: updateCourseCreationItem
    courseCreation: courseCreation
    creationChecklist: creationChecklist
  }
]
