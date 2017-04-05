# This directive manages loading the assignments once for the assignments settings page
@gradecraft.directive 'hasInteractiveAssignments', ['$q', 'AssignmentService', ($q, AssignmentService) ->
  InteractiveAssignmentsCtrl = [()->
    vm = this
    vm.loading = true
    vm.AssignmentService = AssignmentService

    services().then(()->
      vm.loading = false
    )
  ]

  services = ()->
    promises = [AssignmentService.getAssignments()]
    return $q.all(promises)

  {
    bindToController: true,
    controller: InteractiveAssignmentsCtrl,
    controllerAs: 'vm'
  }
]
