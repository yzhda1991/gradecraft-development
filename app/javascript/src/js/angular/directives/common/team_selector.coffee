gradecraft.directive 'teamSelector', ['TeamService', (TeamService) ->
  TeamSelectorCtrl = [() ->
    vm = this
    vm.loading = true

    vm.teams = TeamService.teams
    vm.termForTeam = TeamService.teamTerm
    vm.selectedTeamId = TeamService.selectedTeamId

    TeamService.getTeams(@courseId).finally(() -> vm.loading = false)
  ]

  {
    scope:
      courseId: '@'
    bindToController: true
    controller: TeamSelectorCtrl
    controllerAs: 'teamSelectorCtrl'
    templateUrl: 'common/team_selector.html'
  }
]
