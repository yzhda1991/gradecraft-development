@gradecraft.directive "coursesOverviewTableFilter", ["SortableService", "TableFilterService", (SortableService, TableFilterService) ->
  CoursesOverviewTableFilterCtrl = [() ->
    vm = this
    vm.selectedCriteria = "allCourses"

    vm.setSortCriteria = (criteriaType) ->
      SortableService.filterCriteria(vm.criteria[criteriaType])
      vm.selectedCriteria = criteriaType
      TableFilterService.filterByExpression(vm.criteria[criteriaType])

    vm.criteria = {
      allCourses: (course) => true
      active: (course) => course.active is true
      inactive: (course) => course.active is false
      published: (course) => course.published is true
      unpublished: (course) => course.published is false
      badges: (course) => course.has_badges is true
      sections: (course) => course.has_sections is true
      paid: (course) => course.has_paid is true
      unpaid: (course) => course.has_paid is false
    }
  ]

  {
    bindToController: true
    controller: CoursesOverviewTableFilterCtrl
    controllerAs: "tableFilterCtrl"
    templateUrl: "courses/overview/table_filter.html"
  }
]
