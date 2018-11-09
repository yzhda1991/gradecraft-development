@gradecraft.directive 'unlockSelectorForm', ["CourseService", "UnlockConditionService",
  (CourseService, UnlockConditionService) ->
    UnlockSelectorFormCtrl = [() ->
      vm = this
      vm.loading = true
      vm.selectedCourse = undefined

      vm.courses = CourseService.courses
      vm.unlockConditions = UnlockConditionService.unlockConditions

      vm.checkUnlockables = (unlockConditionId) -> UnlockConditionService.checkUnlockables(unlockConditionId)
      vm.getUnlocks = () -> UnlockConditionService.getUnlockConditionsForCourse(vm.selectedCourse, true) if vm.selectedCourse?

      CourseService.getCourses().then(() -> vm.loading = false)
    ]

    bindToController: true
    controller: UnlockSelectorFormCtrl
    controllerAs: 'unlockSelectorFormCtrl'
    templateUrl: 'admin/unlocks/selector_form.html'
]
