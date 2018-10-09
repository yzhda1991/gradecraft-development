@gradecraft.factory 'CanvasImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []
  courses = []
  assignments = []
  _currentCourseId = ""

  # Getter/setter function that can be bound by a directive
  currentCourseId = (id) ->
    if angular.isDefined(id) then (_currentCourseId = id) else _currentCourseId

  getCourses = (provider) ->
    $http.get("/api/courses/importers/#{provider}/courses").then((response) ->
      GradeCraftAPI.loadMany(courses, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      window.location.replace("/auth/#{provider}") if error.status == 401
      GradeCraftAPI.logResponse(error)
    )

  getAssignments = (provider) ->
    _clearAssignments()
    $http.get("/api/assignments/importers/#{provider}/course/#{_currentCourseId}/assignments").then((response) ->
      GradeCraftAPI.loadMany(assignments, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      window.location.replace("/auth/#{provider}") if error.status == 401
      GradeCraftAPI.logResponse(error)
    )

  getUsers = (provider, courseId, clearUsers, options={}) ->
    _clearUsers() if clearUsers is true
    $http.get("/api/users/importers/#{provider}/course/#{_currentCourseId}/users", params: options).then((response) ->
      GradeCraftAPI.loadMany(users, response.data)
      getUsers(provider, courseId, false, _nextPageParams(response)) if _nextPageParams(response)?
      GradeCraftAPI.logResponse(response)
    , (error) ->
      window.location.replace("/auth/#{provider}") if error.status == 401
      GradeCraftAPI.logResponse(error)
    )

  setUsersSelected = (selectedValue, subset = null) ->
    _.each(subset || users, (user) ->
      user.selected_for_import = selectedValue
      true  # if selected is false, this loop is broken without this line
    )

  setAssignmentsSelected = (selectedValue, subset = null) ->
    _.each(subset || assignments, (assignment) ->
      assignment.selected_for_import = selectedValue
      true  # if selected is false, this loop is broken without this line
    )

  hasSelectedUsers = () ->
    _.any(users, (user) ->
      user.selected_for_import is true
    )

  hasSelectedAssignments = () ->
    _.any(assignments, (assignment) ->
      assignment.selected_for_import is true
    )

  _clearAssignments = () ->
    assignments.length = 0

  _clearUsers = () ->
    users.length = 0

  _nextPageParams = (response) -> response.data.meta.page_params

  {
    users: users
    courses: courses
    assignments: assignments
    currentCourseId: currentCourseId
    getUsers: getUsers
    getCourses: getCourses
    getAssignments: getAssignments
    setUsersSelected: setUsersSelected
    setAssignmentsSelected: setAssignmentsSelected
    hasSelectedUsers: hasSelectedUsers
    hasSelectedAssignments: hasSelectedAssignments
  }
]
