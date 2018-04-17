@gradecraft.directive "assignmentShowGroupTable", ['AssignmentGradesService', (AssignmentGradesService) ->
  AssignmentShowGroupTableCtrl = [() ->
    vm = this
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
