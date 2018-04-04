@gradecraft.directive 'assignmentShowTableHeader', ['AssignmentService', 'AssignmentTypeService', (AssignmentService, AssignmentTypeService) ->
  AssignmentShowTableHeaderCtrl = [() ->
    vm = this
    vm.loading = true
    vm.assignment = AssignmentService.assignment
    vm.assignmentType = AssignmentTypeService.assignmentType

    vm.termFor = (term) -> AssignmentService.termFor(term)

    vm.showScore = () ->
      !vm.assignmentType.student_weightable && !vm.assignment().pass_fail

    vm.showWeightedScore = () ->
      vm.assignmentType.student_weightable && vm.assignment().pass_fail

    vm.showGrade = () ->
      !vm.assignmentType.student_weightable && vm.assignment().pass_fail
  ]

  {
    bindToController: true
    controller: AssignmentShowTableHeaderCtrl
    controllerAs: 'assignmentShowTableHeaderCtrl'
    restrict: 'A'
    templateUrl: 'assignments/show/table_header.html'
  }
]
