@gradecraft.directive "coursesOverview", ["CourseService", "SortableService",
  (CourseService, SortableService) ->
    CoursesOverviewCtrl = [() ->
      vm = this
      vm.loading = true
    ]

    {
      bindToController: true
      controller: CoursesOverviewCtrl
      controllerAs: "coursesOverviewCtrl"
      templateUrl: "courses/overview.html"
    }
]
