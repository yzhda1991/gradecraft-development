@gradecraft.directive "coursesOverviewTableBody", ["CourseService", "PaginationService", "TableFilterService",
  (CourseService, PaginationService, TableFilterService) ->
    CoursesOverviewTableBodyCtrl = [() ->
      vm = this

      vm.courses = CourseService.filteredCourses
      vm.loadingProgress = CourseService.loadingProgress

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
