@gradecraft.factory 'TeamService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  teams = []
  _teamTerm = "Team"
  _selectedTeamId = undefined
  _callback = undefined # an optional callback to invoke after the team id changes

  callback = (callback) ->
    if angular.isDefined(callback)
      _callback = callback
    else
      if not _callback? then null else _callback()

  teamTerm = (term) -> if angular.isDefined(term) then _teamTerm = term else _teamTerm

  selectedTeamId = (teamId) ->
    if angular.isDefined(teamId)
      _selectedTeamId = teamId
      callback()
    else
      _selectedTeamId

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
    callback: callback
  }
]
