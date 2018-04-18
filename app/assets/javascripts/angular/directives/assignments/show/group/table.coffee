@gradecraft.directive "assignmentShowGroupTable", ['AssignmentGradesService', (AssignmentGradesService) ->
  AssignmentShowGroupTableCtrl = [() ->
    vm = this

    vm.termFor = (term) -> AssignmentGradesService.termFor(term)
  ]

  {
    scope:
      linksVisible: "@"
      assignmentId: "@"
    bindToController: true
    controller: AssignmentShowGroupTableCtrl
    controllerAs: "groupTableCtrl"
    templateUrl: "assignments/show/group/table.html"
  }
]
