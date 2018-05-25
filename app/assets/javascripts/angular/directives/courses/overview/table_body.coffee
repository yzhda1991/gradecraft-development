@gradecraft.directive "coursesOverviewTableBody", ["CourseService", "SortableService", "PaginationService", "TableFilterService",
  (CourseService, SortableService, PaginationService, TableFilterService) ->
    CoursesOverviewTableBodyCtrl = [() ->
      vm = this
      vm.sortable = SortableService

      # vm.courses = CourseService.courses
      vm.courses = CourseService.filteredCourses
      vm.paginationOptions = PaginationService.options
      vm.loadingProgress = CourseService.loadingProgress
      vm.filterCriteria = SortableService.filterCriteria

      vm.termFor = (term) -> CourseService.termFor(term)
    ]

    {
      restrict: "C"
      bindToController: true
      controller: CoursesOverviewTableBodyCtrl
      controllerAs: "tableBodyCtrl"
      templateUrl: "courses/overview/table_body.html"
      scope:
        searchCriteria: '='
    }
]
