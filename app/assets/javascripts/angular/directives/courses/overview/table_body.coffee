@gradecraft.directive "coursesOverviewTableBody", ["CourseService",
  (CourseService) ->
    CoursesOverviewTableBodyCtrl = [() ->
      vm = this
      vm.courses = CourseService.courses

      vm.termFor = (term) -> CourseService.termFor(term)
    ]

    {
      restrict: "C"
      bindToController: true
      controller: CoursesOverviewTableBodyCtrl
      controllerAs: "tableBodyCtrl"
      templateUrl: "courses/overview/table_body.html"
    }
]
