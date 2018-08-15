@gradecraft.directive 'assignmentsImportCsvReview', ['AssignmentTypeService', 'AssignmentImporterService',
  (AssignmentTypeService, AssignmentImporterService) ->
    AssignmentsImportCsvReviewCtrl = [()->
      vm = this
      vm.loading = true
      vm.submitted = false

      vm.booleanValues = [
        { display_string: "No", value: false },
        { display_string: "Yes", value: true }
      ]

      vm.assignmentTypes = AssignmentTypeService.assignmentTypes

      vm.hasInvalidDueDates = () ->
        _.any(AssignmentImporterService.assignmentRows, (row) ->
          row.hasInvalidDate is true
        )?

      vm.newAssignmentTypes = () ->
        hasNewAssignmentTypes = _.filter(AssignmentImporterService.assignmentRows, (row) ->
          row.has_matching_assignment_type_id is false and !row.selected_assignment_type? and
            row.assignment_type
        )
        return null if hasNewAssignmentTypes.length < 1
        _.uniq(_.pluck(hasNewAssignmentTypes, 'assignment_type'))

      vm.postImportAssignments = () ->
        vm.submitted = true
        AssignmentImporterService.postImportAssignments(@provider)

      AssignmentTypeService.getAssignmentTypes().finally(() ->
        vm.loading = false
      )
    ]

    {
      scope:
        provider: '@'
        cancelPath: '@'
        assignmentsTerm: '@'
      bindToController: true
      controllerAs: 'vm'
      controller: AssignmentsImportCsvReviewCtrl
      templateUrl: 'assignments/import/csv_review.html'
      link: (scope, elm, attrs) ->
        scope.assignmentRows = AssignmentImporterService.assignmentRows
        scope.results = AssignmentImporterService.results
    }
]
