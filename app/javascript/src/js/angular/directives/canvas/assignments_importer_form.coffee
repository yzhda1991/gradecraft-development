# Main entry point for Canvas assignment importer form
@gradecraft.directive 'canvasAssignmentImporterForm', ['CanvasImporterService', 'AssignmentTypeService', '$sce',
  (CanvasImporterService, AssignmentTypeService, $sce) ->
    CanvasAssignmentImporterCtrl = ['$scope', ($scope) ->
      vm = this
      vm.loading = true
      vm.formSubmitted = false
      vm.selectedAssignmentType = ""

      vm.currentCourseId = CanvasImporterService.currentCourseId
      vm.assignments = CanvasImporterService.assignments
      vm.assignmentTypes = AssignmentTypeService.assignmentTypes

      vm.formAction = () ->
        "/assignments/importers/#{@provider}/courses/#{vm.currentCourseId()}/assignments/import"

      vm.setAssignmentsSelected = (val) ->
        CanvasImporterService.setAssignmentsSelected(val)

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
      link: (scope, el, attr) ->
        scope.hasSelectedAssignments = CanvasImporterService.hasSelectedAssignments

        scope.sanitize = (html) ->
          $sce.trustAsHtml(html)
    }
]
