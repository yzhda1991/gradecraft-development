# Main entry point for editing rubrics

@gradecraft.directive 'rubricDesign', ['$q', 'RubricService', 'BadgeService', ($q, RubricService, BadgeService) ->
  RubricDesignCtrl = [()->
    vm = this

    vm.loading = true
    vm.RubricService = RubricService

    vm.rubric = RubricService.rubric
    vm.criteria = RubricService.criteria
    vm.full_points = RubricService.full_points

    vm.badges = BadgeService.badges

    vm.openNewCriterion = ()->
      RubricService.openNewCriterion()

    vm.hasNewCriterion = ()->
      _.filter(vm.criteria, { new_criteria: true }).length > 0

    services(vm.rubricId).then(()->
      vm.loading = false
    )

  ]

  services = (rubricId)->
    promises = [
      RubricService.getRubric(rubricId)
      BadgeService.getBadges()
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
