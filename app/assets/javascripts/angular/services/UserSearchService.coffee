@gradecraft.factory 'UserSearchService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->
  users = []

  getSearchResults = (firstName, lastName, email) ->
    $http.get("/api/users/search", params: { first_name: firstName, last_name: lastName, email: email }).then((response) ->
      GradeCraftAPI.loadMany(users, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      alert "Failure"
    )

  {
    getSearchResults: getSearchResults
  }
]
