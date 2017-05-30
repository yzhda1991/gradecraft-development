# Main entry point for Canvas course selector
@gradecraft.directive 'canvasCourseSelector', ['CanvasImporterService', (CanvasImporterService) ->
  CanvasCourseSelectorCtrl = [() ->
    vm = this
    vm.loading = true

    vm.courses = CanvasImporterService.courses
    vm.currentCourseId = CanvasImporterService.currentCourseId

    CanvasImporterService.getCourses(@provider).finally(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      provider: '@'
    bindToController: true
    controller: CanvasCourseSelectorCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'canvas/course_selector.html'
  }
]
