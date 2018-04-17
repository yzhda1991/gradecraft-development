@gradecraft.directive "assignmentShowGroupTable", ['AssignmentGradesService', (AssignmentGradesService) ->
  AssignmentShowGroupTableCtrl = [() ->
    vm = this
    vm.loading = false

    AssignmentGradesService.getGroupAssignmentWithGrades(@assignmentId).then(() -> vm.loading = false)
  ]

  {
    scope:
      assignmentId: "@"
    bindToController: true
    controller: AssignmentShowGroupTableCtrl
    controllerAs: "groupTableCtrl"
    templateUrl: "assignments/show/group/table.html"
  }
]
