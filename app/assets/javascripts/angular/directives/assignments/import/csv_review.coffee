@gradecraft.directive 'assignmentsImportCsvReview',
  ['AssignmentTypeService', 'AssignmentImporterService', (AssignmentTypeService, AssignmentImporterService) ->
    AssignmentsImportCsvReviewCtrl = [()->
      vm = this
      vm.loading = true

      vm.assignmentTypes = AssignmentTypeService.assignmentTypes

      vm.postImportAssignments = () ->
        AssignmentImporterService.postImportAssignments(@provider)

      AssignmentTypeService.getAssignmentTypes().finally(() ->
        vm.loading = false
      )
    ]

    {
      scope:
        provider: '@'
        cancelPath: '@'
      bindToController: true
      controllerAs: 'vm'
      controller: AssignmentsImportCsvReviewCtrl
      templateUrl: 'assignments/import/csv_review.html'
      link: (scope, elm, attrs) ->
        scope.assignmentRows = AssignmentImporterService.assignmentRows
    }
  ]
