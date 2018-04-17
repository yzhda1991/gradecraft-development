@gradecraft.directive "assignmentShowGroupTableBody", ['AssignmentGradesService', (AssignmentGradesService) ->
  AssignmentShowGroupTableBodyCtrl = [() ->
    vm = this
    vm.loading = true
    vm.groupGrades = AssignmentGradesService.groupGrades

    AssignmentGradesService.getGroupGradesForAssignment(@assignmentId).then(() -> vm.loading = false)
  ]

  {
    bindToController: true
    controller: AssignmentShowGroupTableBodyCtrl
    controllerAs: "groupTableBodyCtrl"
    templateUrl: "assignments/show/group/table_body.html"
  }
]
