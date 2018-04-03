@gradecraft.directive 'assignmentShowTableBody', ['AssignmentService', 'AssignmentTypeService', 'StudentService',
  (AssignmentService, AssignmentTypeService, StudentService) ->
    AssignmentShowTableBodyCtrl = [() ->
      vm = this
      vm.loading = true
      vm.assignment = AssignmentService.assignment
      vm.assignmentType = AssignmentTypeService.assignmentType
      vm.students = StudentService.students

      vm.tooltipDescribedBy = (type="feedback-read-tip")->
        "#{type}_#{vm.assignment().id}"

      vm.termFor = (term) -> StudentService.termFor(term)

      vm.showPassFailStatus = (student) ->
        vm.assignment().pass_fail && student.grade_instructor_modified &&
          student.grade_pass_fail_status?

      StudentService.getForAssignment(vm.assignment().id).then(() ->
        vm.loading = false
      )
    ]

    {
      bindToController: true
      controller: AssignmentShowTableBodyCtrl
      controllerAs: 'assignmentShowTableBodyCtrl'
      restrict: 'A'
      templateUrl: 'assignments/show/table_body.html'
    }
]
