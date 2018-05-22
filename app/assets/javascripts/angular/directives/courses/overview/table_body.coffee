@gradecraft.directive "coursesOverviewTableBody", ["CourseService", "SortableService",
  (CourseService, SortableService) ->
    CoursesOverviewTableBodyCtrl = [() ->
      vm = this
      vm.courses = CourseService.courses
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
