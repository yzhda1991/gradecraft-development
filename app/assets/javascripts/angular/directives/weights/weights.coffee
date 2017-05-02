@gradecraft.directive 'assignmentTypeWeights', ['$q', 'AssignmentTypeService', ($q, AssignmentTypeService) ->
    WeightsCtrlr = [()->
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
      controller: WeightsCtrlr,
      controllerAs: 'vm',
      restrict: 'EA',
      scope: {
        studentId: "="
      },
      templateUrl: 'weights/assignment_type_weights.html'
    }
]

