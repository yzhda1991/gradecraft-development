@gradecraft.factory 'TeamService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  teams = []

  getTeams = (courseId) ->
    $http.get("/api/courses/#{courseId}/teams").then((response) ->
      angular.copy(response.data, teams)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  {
    teams: teams
    getTeams: getTeams
  }
]
