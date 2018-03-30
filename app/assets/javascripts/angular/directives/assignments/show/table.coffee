@gradecraft.directive 'assignmentShowTable', ['AssignmentService', 'AssignmentTypeService', '$q', (AssignmentService, AssignmentTypeService, $q) ->
  AssignmentShowTableCtrl = [() ->
    vm = this
    vm.loading = true

    services(@assignmentId, @assignmentTypeId).then(() ->
      vm.loading = false
    )
  ]

  services = (assignmentId, assignmentTypeId) ->
    promises = [
      AssignmentService.getAssignment(assignmentId),
      AssignmentTypeService.getAssignmentType(assignmentTypeId)
    ]
    $q.all(promises)

  {
    scope:
      assignmentId: '@'
      assignmentTypeId: '@'
    bindToController: true
    controller: AssignmentShowTableCtrl
    controllerAs: 'assignmentShowTableCtrl'
    restrict: 'EA'
    templateUrl: 'assignments/show/table.html'
  }
]
