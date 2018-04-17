@gradecraft.directive "assignmentShowGroupTableBody", ['GroupService', (GroupService) ->
  AssignmentShowGroupTableBodyCtrl = [() ->
    vm = this
    vm.loading = false
  ]

  {
    bindToController: true
    controller: AssignmentShowGroupTableBodyCtrl
    controllerAs: "groupTableBodyCtrl"
    templateUrl: "assignments/show/group/table_body.html"
  }
]
