@gradecraft.directive "coursesOverview", ["CourseService", "SortableService",
  (CourseService, SortableService) ->
    CoursesOverviewCtrl = [() ->
      vm = this
      vm.loading = true
      vm.searchCriteria = undefined
      vm.hasCourses = CourseService.hasCourses

      CourseService.getCourses().then(() -> vm.loading = false)
    ]

    {
      bindToController: true
      controller: CoursesOverviewCtrl
      controllerAs: "coursesOverviewCtrl"
      templateUrl: "courses/overview.html"
    }
]
