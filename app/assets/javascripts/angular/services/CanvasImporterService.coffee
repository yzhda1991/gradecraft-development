@gradecraft.factory 'CanvasImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  courses = []
  assignments = []
  _currentCourseId = ""

  currentCourseId = (id) ->
    if angular.isDefined(id) then (_currentCourseId = id) else _currentCourseId

  getCourses = (provider) ->
    $http.get("/integrations/#{provider}/courses").then((response) ->
      GradeCraftAPI.loadMany(courses, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  getAssignments = (assignmentId, provider) ->
    # TODO: refactor out assignmentId in API route
    _clearAssignments()
    return unless _currentCourseId
    $http.get("/assignments/#{assignmentId}/grades/importers/#{provider}/courses/#{_currentCourseId}/assignments").then((response) ->
      GradeCraftAPI.loadMany(assignments, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  _clearAssignments = () ->
    assignments.length = 0

  {
    courses: courses
    assignments: assignments
    _currentCourseId: _currentCourseId
    currentCourseId: currentCourseId
    getCourses: getCourses
    getAssignments: getAssignments
  }
]
