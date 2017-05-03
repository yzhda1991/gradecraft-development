# Main entry point for grading (standard/rubric individual/group)
# Renders appropriate grading form for grade and assignment type

@gradecraft.directive 'rubricDesign', ['$q', 'RubricService', ($q, RubricService) ->
  RubricDesignCtrl = [()->
    vm = this

    vm.loading = true
    vm.RubricService = RubricService

    vm.rubric = RubricService.rubric
    vm.criteria = RubricService.cirteria
    vm.full_points = RubricService.full_points

    services(vm.rubricId).then(()->
      vm.loading = false
    )

    vm.createCriterion = ()->
      console.log("createCriterion");
    vm.createLevel = ()->
      console.log("createLevel");
    vm.criterionIsNew = ()->
      console.log("criterionIsNew");
    vm.criterionIsSaved = ()->
      console.log("criterionIsSaved");
    vm.insertLevel = (criterion)->
      console.log("insertLevel");
    vm.levelIsSaved = ()->
      console.log("levelIsSaved");
    vm.pointsAssigned = ()->
      console.log("pointsAssigned");
    vm.pointsMeetExpectations = ()->
      console.log("pointsMeetExpectations");
    vm.pointsMissing = ()->
      console.log("pointsMissing");
    vm.pointsOverage = ()->
      console.log("pointsOverage");
    vm.pointsRemaining = ()->
      console.log("pointsRemaining");
    vm.pointsSatisfied = ()->
      console.log("pointsSatisfied");

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
