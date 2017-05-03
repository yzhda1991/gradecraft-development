# Main entry point for grading (standard/rubric individual/group)
# Renders appropriate grading form for grade and assignment type

@gradecraft.directive 'rubricDesign', ['$q', 'RubricService', ($q, RubricService) ->
  RubricDesignCtrl = [()->
    vm = this

    vm.loading = true
    vm.RubricService = RubricService

    vm.rubric = RubricService.rubric
    vm.criteria = RubricService.criteria
    vm.full_points = RubricService.full_points

    services(vm.rubricId).then(()->
      vm.loading = false
    )

  ]

  services = (rubricId)->
    promises = [
      RubricService.getRubric(rubricId)
    ]
    return $q.all(promises)

  {
    bindToController: true,
    controller: RubricDesignCtrl,
    controllerAs: 'vm',
    scope: {
       rubricId: "="
    },
    templateUrl: 'rubrics/design.html'
  }
]
