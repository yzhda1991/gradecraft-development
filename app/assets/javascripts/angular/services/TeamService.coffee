@gradecraft.factory 'TeamService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  teams = []
  _teamTerm = "Team"
  _selectedTeamId = ""

  teamTerm = (term) -> if angular.isDefined(term) then _teamTerm = term else _teamTerm

  selectedTeamId = (teamId) -> if angular.isDefined(teamId) then (_selectedTeamId = teamId) else _selectedTeamId

  getTeams = (courseId) ->
    $http.get("/api/courses/#{courseId}/teams").then((response) ->
      angular.copy(response.data.teams, teams)
      teamTerm(response.data.term_for_team)
      GradeCraftAPI.logResponse(response)
    , (error) ->
      GradeCraftAPI.logResponse(error)
    )

  {
    teams: teams
    teamTerm: teamTerm
    selectedTeamId: selectedTeamId
    getTeams: getTeams
  }
]
