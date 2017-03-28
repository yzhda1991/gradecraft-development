@gradecraft.factory 'UserSearchService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  users = []

  searchCriteria = {
    firstName: undefined
    lastName: undefined
    email: undefined
    username: undefined
  }

  getSearchResults = (searchType) ->
    _clearSearchResults()
    params = _paramsForSearchType(searchType)
    $http.get("/api/users/search", params: params).then((response) ->
      GradeCraftAPI.loadMany(users, response.data)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      console.error "Not found"
    )

  _paramsForSearchType = (searchType) ->
    params = {}
    if searchType is 'Name'
      params.first_name = searchCriteria.firstName
      params.last_name = searchCriteria.lastName
    else if searchType is 'Email'
      params.email = searchCriteria.email
    else if searchType is 'Username'
      params.username = searchCriteria.username
    params

  _clearSearchResults = () ->
    users.length = 0

  {
    users: users
    searchCriteria: searchCriteria
    getSearchResults: getSearchResults
  }
]
