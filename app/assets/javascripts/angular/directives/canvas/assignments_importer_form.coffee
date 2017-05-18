# Main entry point for Canvas assignment importer form
@gradecraft.directive 'canvasAssignmentImporterForm', ['CanvasImporterService', 'AssignmentTypeService',
  (CanvasImporterService, AssignmentTypeService) ->
    CanvasAssignmentImporterCtrl = ['$scope', '$sce', ($scope, $sce) ->
      vm = this
      vm.loading = true
      vm.formSubmitted = false
      vm.selectedAssignmentType = ""

      vm.currentCourseId = CanvasImporterService.currentCourseId
      vm.assignments = CanvasImporterService.assignments
      vm.assignmentTypes = AssignmentTypeService.assignmentTypes

      vm.formAction = () ->
        "/assignments/importers/#{@provider}/courses/#{vm.currentCourseId()}/assignments/import"

      vm.renderDescription = (description) ->
        $sce.trustAsHtml(description)

      # The service keeps track of the current Canvas course context;
      # when the course changes, we should fetch the new set of assignments
      $scope.$watch(() ->
        vm.currentCourseId()
      , (newValue, oldValue) ->
        CanvasImporterService.getAssignments(vm.provider) if newValue
      )

      AssignmentTypeService.getAssignmentTypes().finally(() ->
        vm.loading = false
      )
    ]

    {
      scope:
        provider: '@'
        currentCourseName: '@'
        authenticityToken: '@'  # for the form submit
      bindToController: true
      controller: CanvasAssignmentImporterCtrl
      controllerAs: 'vm'
      restrict: 'EA'
      templateUrl: 'canvas/assignments_importer_form.html'
    }
]
