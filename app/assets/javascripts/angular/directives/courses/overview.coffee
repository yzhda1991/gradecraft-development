@gradecraft.directive "coursesOverview", ["CourseService", "SortableService", "TableFilterService",
  (CourseService, SortableService, TableFilterService) ->
    CoursesOverviewCtrl = [() ->
      vm = this
      vm.loading = true
      vm.searchCriteria = undefined
      vm.hasCourses = CourseService.hasCourses
      vm.courses = CourseService.filteredCourses

      vm.filterByTerm = () -> TableFilterService.filterByTerm(vm.searchCriteria)

      CourseService.getBatchedCourses().then(() -> vm.loading = false)
    ]

    {
      bindToController: true
      controller: CoursesOverviewCtrl
      controllerAs: "coursesOverviewCtrl"
      templateUrl: "courses/overview.html"
    }
]
