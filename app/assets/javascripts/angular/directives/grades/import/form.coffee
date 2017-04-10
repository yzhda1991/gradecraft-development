# Main entry point for rendering a Canvas grade row
@gradecraft.directive 'gradeImportForm', ['GradeImporterService', '$q', (GradeImporterService, $q) ->
  gradeImportFormCtrl = [() ->
    vm = this
    vm.loading = true

    vm.detailsLink = "/assignments/#{@currentAssignmentId}/grades/importers/#{@provider}/courses/#{@courseId}/assignments"
    vm.formAction = () ->
      base_url = "/assignments/#{@currentAssignmentId}/grades/importers/#{@provider}/courses/#{@courseId}/grades/import"
      base_url + "?assignment_ids=#{@assignmentIds}"

    vm.selectAllGrades = () ->
      GradeImporterService.selectAllGrades()

    vm.deselectAllGrades = () ->
      GradeImporterService.deselectAllGrades()

    vm.hasSelectedGrades = () ->
      _.any(GradeImporterService.grades, (grade) ->
        grade.selected_for_import is true
      )

    initialize(@currentAssignmentId, @courseId, @provider, @assignmentIds).then(() ->
      vm.loading = false
    )
  ]

  initialize = (currentAssignmentId, courseId, provider, assignmentIds) ->
    promises = [
      GradeImporterService.getGrades(currentAssignmentId, courseId, provider, assignmentIds)
      GradeImporterService.getAssignment(currentAssignmentId)
    ]
    $q.all(promises)

  {
    scope:
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
      scope.assignment = GradeImporterService.assignment
  }
]
