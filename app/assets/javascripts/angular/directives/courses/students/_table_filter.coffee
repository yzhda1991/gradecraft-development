@gradecraft.directive "coursesStudentsIndexTableFilter", ["SortableService", "StudentService", "orderByFilter", (SortableService, StudentService, orderBy) ->
  TableFilterCtrl = [() ->
    vm = this
    vm.termFor = StudentService.termFor

    vm.selectedCriteria = undefined

    vm.setSortCriteria = (criteriaType) ->
      vm.selectedCriteria = criteriaType
      SortableService.filterCriteria(vm.criteria[criteriaType])
      # don't recalculate ranks if selecting top10, bottom10 filters
      @filterCallback()(criteriaType not in ["top10", "bottom10"]) if @filterCallback?

    # comparator functions for table filter
    vm.criteria = {
      allStudents: (student) => true
      activeStudents: (student) => student.activated_for_course
      leaderboard: (student) => student.rank? && student.activated_for_course
      flaggedStudents: (student) => student.flagged and student.activated_for_course
      top10: (student) => student.rank? and student.activated_for_course and parseInt(student.rank) <= 10
      bottom10: (student) => student.id in vm.bottom10
      auditors: (student) => not student.rank? and student.activated_for_course
      deactivated: (student) => not student.activated_for_course
    }

    _initialize(vm)
  ]

  _initialize = (vm) ->
    vm.setSortCriteria("leaderboard")
    ranked = _.filter(vm.collection, "rank")
    bottom10 = _.takeRight(orderBy(ranked, "rank"), 10)
    vm.bottom10 = _.pluck(bottom10, "id")

  {
    scope:
      collection: "="
      filterCallback: "&"
    bindToController: true
    controller: TableFilterCtrl
    controllerAs: "tableFilterCtrl"
    templateUrl: "courses/students/_table_filter.html"
  }
]
