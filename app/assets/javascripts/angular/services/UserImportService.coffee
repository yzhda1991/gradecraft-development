@gradecraft.factory 'UserImportService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []

  getUsers = (provider, courseId, options={}) ->
    $http.get("/api/users/import", params: _requestParams(options)).then(
      (response) ->
        # GradeCraftAPI.loadMany(users, response.data)
        GradeCraftAPI.logResponse(response)
      , (error) ->
        GradeCraftAPI.logResponse(error)
        console.error "An error occurred while loading users from #{provider}"
    )

  _requestParams = (options) ->
    {
      # TODO
    }

  {
    users: users
    getUsers: getUsers
  }
]
