gradecraft.directive "dashboardInstructorAssignmentList", ["DashboardService", (DashboardService) ->
  DashboardInstructorAssignmentList = [() ->
    vm = this
    vm.termFor = (term) -> DashboardService.termFor(term)

    vm.hasAssignments = () -> _.any(@assignments)
  ]

  {
    scope:
      assignments: "="
    bindToController: true
    controller: DashboardInstructorAssignmentList
    controllerAs: "instructorAssignmentList"
    restrict: "EA"
    templateUrl: "dashboard/instructor_assignment_list.html"
  }
]
