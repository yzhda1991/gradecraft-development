@gradecraft.factory 'UserImporterService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []
  hasError = false

  getUsers = (provider, courseId) ->
    $http.get("/api/users/importers/#{provider}/course/#{courseId}/users").then((response) ->
      GradeCraftAPI.loadMany(users, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      hasError = true
      window.location.replace("/auth/#{provider}") if error.status == 401
      GradeCraftAPI.logResponse(error)
    )

  # Sets value to dictate whether all users should be selected/deselected for import
  setUsersSelected = (selectedValue, subset = null) ->
    _.each(subset || users, (user) ->
      user.selected_for_import = selectedValue
      true  # if selected is false, this loop is broken without this line
    )

  unchangedUsers = () ->
    _.filter(users, (user) ->
      user.user_exists is true and user.role_changed is false
    )

  changedUsers = () ->
    _.filter(users, (user) ->
      user.user_exists is true and user.role_changed is true
    )

  newUsers = () ->
    _.filter(users, (user) ->
      user.user_exists is false
    )

  checkHasError = () ->
    hasError

  {
    users: users
    hasError: hasError
    getUsers: getUsers
    newUsers: newUsers
    changedUsers: changedUsers
    unchangedUsers: unchangedUsers
    setUsersSelected: setUsersSelected
    checkHasError: checkHasError
  }
]
