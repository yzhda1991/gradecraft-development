@gradecraft.factory 'UserSearchService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []

  getSearchResults = (firstName, lastName, email) ->
    _clearUserArray()
    $http.get("/api/users/search", params: { first_name: firstName, last_name: lastName, email: email }).then((response) ->
      GradeCraftAPI.loadMany(users, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      console.error "Not found"
    )

  _clearUserArray = () ->
    users.length = 0

  {
    users: users
    getSearchResults: getSearchResults
  }
]
