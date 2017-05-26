@gradecraft.directive 'teamSelector', ['TeamService', (TeamService) ->
  TeamSelectorCtrl = [() ->
    vm = this

    vm.loading = true
    vm.selectedTeam = null
    vm.termForTeam = @teamTerm || "Team"

    TeamService.getTeams(@courseId).finally(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      courseId: '@'
      teamTerm: '@'
    bindToController: true
    controller: TeamSelectorCtrl
    controllerAs: 'teamSelector'
    templateUrl: 'common/team_selector.html'
    link: (scope, element, attrs) ->
      scope.teams = TeamService.teams
  }
]
