@gradecraft.directive "assignmentShowGroupStudentTable", ["AssignmentGradesService", "AssignmentService", "AssignmentTypeService",
  (AssignmentGradesService, AssignmentService, AssignmentTypeService) ->
    AssignmentShowGroupStudentTableCtrl = [() ->
      vm = this
      vm.assignment = AssignmentService.assignment
      vm.assignmentType = AssignmentTypeService.assignmentType
      vm.students = AssignmentGradesService.students

      vm.loading = () -> !AssignmentTypeService.assignmentType()?

      vm.gradesForGroup = () -> AssignmentGradesService.gradesForGroup(@group)
      vm.termFor = (term) -> AssignmentGradesService.termFor(term)

      vm.showPassFailStatus = (grade) -> vm.assignment().pass_fail && grade.pass_fail_status?
    ]

    {
      scope:
        group: "="
      restrict: "A"
      bindToController: true
      controller: AssignmentShowGroupStudentTableCtrl
      controllerAs: "groupStudentTableCtrl"
      templateUrl: "assignments/show/group/_student_table.html"
    }
]
