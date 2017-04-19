@gradecraft.factory 'UserImportService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []
  hasError = false

  getUsers = (provider, courseId, options={}) ->
    $http.get("/api/users/importers/#{provider}/course/#{courseId}/users",
      params: _requestParams(options)).then(
        (response) ->
          GradeCraftAPI.loadMany(users, response.data)
          GradeCraftAPI.logResponse(response)
        , (error) ->
          hasError = true
          GradeCraftAPI.logResponse(error)
          console.error "An error occurred while loading users from #{provider}"
      )

  # Sets value to dictate whether all users should be selected/deselected for import
  setUsersSelected = (selectedValue) ->
    _.each(users, (user) ->
      user.selected_for_import = selectedValue
      true  # if selected is false, this loop is broken without this line
    )

  _requestParams = (options) ->
    {
      # TODO
    }

  {
    users: users
    getUsers: getUsers
    setUsersSelected: setUsersSelected
  }
]
