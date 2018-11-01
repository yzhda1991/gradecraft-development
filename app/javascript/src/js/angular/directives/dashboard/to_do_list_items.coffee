gradecraft.directive "dashboardToDoListItems", ["DashboardService", "$sce", (DashboardService, $sce) ->
  DashboardToDoListItemsCtrl = [() ->
    vm = this
    vm.data = DashboardService.dueThisWeekData
    vm.termFor = (term) -> DashboardService.termFor(term)
    vm.sanitize = (html) -> $sce.trustAsHtml(html)

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
