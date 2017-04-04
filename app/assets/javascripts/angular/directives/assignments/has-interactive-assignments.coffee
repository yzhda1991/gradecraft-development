# This directive manages loading the assignments for the assignments settings page
# The individual assignments each have their own component to toggle booleans, and
# rely on these assignments being loaded on page load.

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
    controllerAs: 'vm',
    scope: {
      assignmentId: "=",
    }
  }
]
