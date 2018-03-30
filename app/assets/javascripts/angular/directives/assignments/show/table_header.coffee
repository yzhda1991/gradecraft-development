@gradecraft.directive 'assignmentShowTableHeader', ['AssignmentService', 'AssignmentTypeService', (AssignmentService, AssignmentTypeService) ->
  AssignmentShowTableHeaderCtrl = [() ->
    vm = this
    vm.loading = true
    vm.assignment = AssignmentService.assignment
    vm.assignmentType = AssignmentTypeService.assignmentType

    vm.termFor = (term) -> AssignmentService.termFor(term)
  ]

  {
    bindToController: true
    controller: AssignmentShowTableHeaderCtrl
    controllerAs: 'assignmentShowTableHeaderCtrl'
    restrict: 'EA'
    templateUrl: 'assignments/show/table_header.html'
  }
]
