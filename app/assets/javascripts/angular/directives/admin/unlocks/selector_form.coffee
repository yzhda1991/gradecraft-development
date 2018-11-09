@gradecraft.directive 'unlockSelectorForm', ["CourseService", (CourseService) ->
  UnlockSelectorFormCtrl = [()->
    vm = this
    vm.loading = true
    vm.selectedCourse = undefined
    vm.courses = CourseService.courses

    vm.getUnlocks = () -> console.log("TODO")

    CourseService.getCourses().then(() -> vm.loading = false)
  ]

  bindToController: true,
  controller: UnlockSelectorFormCtrl,
  controllerAs: 'unlockSelectorFormCtrl',
  templateUrl: 'admin/unlocks/selector_form.html'
]
