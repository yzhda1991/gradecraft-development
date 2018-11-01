gradecraft.directive "dashboardToDoList", ["DashboardService", (DashboardService) ->
  DashboardToDoListCtrl = [() ->
    vm = this
    vm.loading = true
    vm.tab = "coursePlanner"

    vm.data = DashboardService.dueThisWeekData
    vm.coursePlannerAssignments = DashboardService.dueThisWeekAssignments
    vm.plannerAssignments = DashboardService.plannerAssignments

    vm.termFor = (term) -> DashboardService.termFor(term)

    DashboardService.getDueThisWeek().then(() ->
      vm.data = DashboardService.dueThisWeekData
      vm.loading = false
    )
  ]

  {
    bindToController: true
    controller: DashboardToDoListCtrl
    controllerAs: "toDoListCtrl"
    restrict: "EA"
    templateUrl: "dashboard/to_do_list.html"
  }
]
