# Main entry point for Canvas assignment selector
@gradecraft.directive 'canvasAssignmentsSelector', ['CanvasImporterService', (CanvasImporterService) ->
  CanvasAssignmentsSelectorCtrl = ['$scope', '$sce', ($scope, $sce) ->
    vm = this
    vm.loading = false
    vm.currentCourseId = CanvasImporterService.currentCourseId

    vm.pathForAssignment = (assignmentId) ->
      "/assignments/#{@assignmentId}/grades/importers/#{@provider}/courses/#{vm.currentCourseId()}/grades?assignment_ids=#{assignmentId}"

    vm.renderDescription = (description) ->
      $sce.trustAsHtml(description)

    vm.assignments = CanvasImporterService.assignments

    vm.getAssignments = () ->
      vm.loading = true
      CanvasImporterService.getAssignments(vm.assignmentId, vm.provider).finally(() ->
        vm.loading = false
      )

    # The service keeps track of the current Canvas course context;
    # when the course changes, we should fetch the new set of assignments
    $scope.$watch(() ->
      vm.currentCourseId()
    , (newValue, oldValue) ->
      vm.getAssignments() if newValue
    )
  ]

  {
    scope:
      provider: '@'
      assignmentId: '@'
    bindToController: true
    controller: CanvasAssignmentsSelectorCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'canvas/assignments_selector.html'
  }
]
