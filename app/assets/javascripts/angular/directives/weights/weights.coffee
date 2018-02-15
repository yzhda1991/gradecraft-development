# This directive was explicitly for the /assignment_type_weights index page,
# which is not currently an active route, and can probably be removed.
# all student weighting currently is faciliated through the predictor.
@gradecraft.directive 'assignmentTypeWeights', ['$q', 'AssignmentTypeService', ($q, AssignmentTypeService) ->
  WeightsCtrl = [()->
    vm = this

    vm.loading = true
    vm.assignmentTypes = AssignmentTypeService.assignmentTypes
    vm.weights = AssignmentTypeService.weights

    vm.termFor = (term)->
      AssignmentTypeService.termFor(term)

    vm.unusedWeightsRange = ()->
      AssignmentTypeService.unusedWeightsRange()

    vm.weightsAvailable = ()->
      AssignmentTypeService.weightsAvailable()

    services().then(()->
      vm.loading = false
    )
  ]

  services = ()->
    promises = [AssignmentTypeService.getAssignmentTypes()]
    return $q.all(promises)

  {
    bindToController: true,
    controller: WeightsCtrl,
    controllerAs: 'vm',
    restrict: 'EA',
    templateUrl: 'weights/assignment_type_weights.html'
  }
]
