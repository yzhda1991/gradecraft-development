@gradecraft.directive "coursesOverviewTableBody", ["CourseService", "SortableService", "PaginationService", "TableFilterService",
  (CourseService, SortableService, PaginationService, TableFilterService) ->
    CoursesOverviewTableBodyCtrl = [() ->
      vm = this
      vm.sortable = SortableService

      vm.courses = CourseService.filteredCourses
      vm.loadingProgress = CourseService.loadingProgress
      vm.filterCriteria = SortableService.filterCriteria

      vm.paginationOptions = PaginationService.options
      vm.startFromIndex = PaginationService.startFromIndex

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
