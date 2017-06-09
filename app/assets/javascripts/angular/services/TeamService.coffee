@gradecraft.factory 'TeamService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  teams = []
  _selectedTeamId = ""

  selectedTeamId = (teamId) ->
    if angular.isDefined(teamId) then (_selectedTeamId = teamId) else _selectedTeamId

  getTeams = (courseId) ->
    $http.get("/api/courses/#{courseId}/teams").then((response) ->
      angular.copy(response.data, teams)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  {
    teams: teams
    selectedTeamId: selectedTeamId
    getTeams: getTeams
  }
]
