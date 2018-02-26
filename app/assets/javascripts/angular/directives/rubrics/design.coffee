# Main entry point for editing rubrics
@gradecraft.directive "rubricDesign", ["$q", "RubricService", "BadgeService", "$timeout", ($q, RubricService, BadgeService, $timeout) ->
  RubricDesignCtrl = [() ->
    vm = this

    vm.loading = true
    vm.RubricService = RubricService

    vm.termFor = BadgeService.termFor
    vm.rubric = RubricService.rubric
    vm.criteria = RubricService.criteria
    vm.full_points = RubricService.full_points
    vm.gradeWithRubric = RubricService.gradeWithRubric
    vm.copyRubricPath = RubricService.copyRubricPath
    vm.badges = BadgeService.badges

    vm.openNewCriterion = () ->
      RubricService.openNewCriterion()

    vm.hasNewCriterion = () ->
      _.filter(vm.criteria, { newCriterion: true }).length > 0

    vm.dragStart = (e, ui) ->
      ui.item.data "start", ui.item.index()

    vm.dragEnd = (e, ui) ->
      start = ui.item.data("start")
      end = ui.item.index()
      RubricService.updateCriterionOrder(start, end)

    vm.initSortable = () ->
      angular.element("#criterion-box").sortable(
        start: vm.dragStart
        update: vm.dragEnd
        handle: ".criterion-drag-handle"
      )

    services(vm.rubricId).then(() ->
      vm.loading = false
      $timeout(() -> vm.initSortable()) # once done loading and digest cycle is complete
    )
  ]

  services = (rubricId) ->
    promises = [
      RubricService.getRubric(rubricId)
      BadgeService.getBadges()
    ]
    $q.all(promises)

  {
    scope:
       rubricId: "="
    bindToController: true
    controller: RubricDesignCtrl
    controllerAs: "vm"
    templateUrl: "rubrics/design.html"
    link: (scope, el, attr) ->
      scope.reordering = false

      scope.toggleReordering = () ->
        scope.reordering = !scope.reordering

      scope.orderButtonText = () ->
        if scope.reordering
          "End Reordering Criteria"
        else
          "Reorder Criteria"
  }
]
