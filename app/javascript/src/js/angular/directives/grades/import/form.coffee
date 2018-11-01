# Main entry point for rendering the grade import form with data from the
# the LMS provider
gradecraft.directive 'gradeImportForm', ['GradeImporterService', (GradeImporterService) ->
  gradeImportFormCtrl = [() ->
    vm = this
    vm.loading = true
    vm.formSubmitted = false

    vm.assignmentLink = "/assignments/#{@currentAssignmentId}/grades/importers/#{@provider}/assignments"
    vm.formAction = "/assignments/#{@currentAssignmentId}/grades/importers/#{@provider}/courses/#{@courseId}/grades/import"

    vm.hasError = () -> GradeImporterService.checkHasError()
    vm.selectAllGrades = () -> GradeImporterService.selectAllGrades()
    vm.deselectAllGrades = () -> GradeImporterService.deselectAllGrades()

    vm.hasSelectedGrades = () ->
      _.any(GradeImporterService.grades, (grade) -> grade.selected_for_import is true)

    vm.termForUserExists = (value) ->
      if value is true then "Yes" else "No"

    GradeImporterService.getGrades(@currentAssignmentId, @courseId, @provider, @assignmentIds).finally(() ->
      vm.loading = false
    )
  ]

  {
    # authenticityToken: for the form submit
    # assignmentName: the GC name of the assignment to import grades to
    # assignmentIds: the provider assignments id(s) to import grades from
    # currentAssignmentId: the GC assignment id to import grades to
    # courseId: the provider course id
    scope:
      authenticityToken: '@'
      assignmentName: '@'
      assignmentIds: '@'
      currentAssignmentId: '@'
      courseId: '@'
      provider: '@'
    bindToController: true
    controller: gradeImportFormCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'grades/import/form.html'
    link: (scope, element, attr) ->
      scope.grades = GradeImporterService.grades
      scope.termFor = GradeImporterService.termFor
  }
]
