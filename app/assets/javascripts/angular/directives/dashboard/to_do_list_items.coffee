@gradecraft.directive "dashboardToDoListItems", ["DashboardService", (DashboardService) ->
  DashboardToDoListItemsCtrl = [() ->
    vm = this
    vm.data = DashboardService.dueThisWeekData
    vm.termFor = (term) -> DashboardService.termFor(term)

    vm.hasAssignments = () -> _.any(@assignments)
  ]

  {
    scope:
      assignments: "="
      assignmentType: '@'
    bindToController: true
    controller: DashboardToDoListItemsCtrl
    controllerAs: "toDoListItemsCtrl"
    restrict: "EA"
    templateUrl: "dashboard/to_do_list_items.html"
  }
]
