# A table of assignments with editable grades
@gradecraft.directive 'massEditForm', ['AssignmentGradesService', 'TeamService', (AssignmentGradesService, TeamService) ->
  MassEditFormCtrl = ['$scope', ($scope)->
    vm = this
    vm.loading = true

    vm.assignment = AssignmentGradesService.assignment
    vm.grades = AssignmentGradesService.grades
    vm.termFor = AssignmentGradesService.termFor
    vm.selectedTeamId = TeamService.selectedTeamId

    $scope.$watch(() ->
      vm.selectedTeamId()
    , (newValue, oldValue) ->
      AssignmentGradesService.getAssignmentWithGrades(vm.assignmentId, newValue)
    )

    AssignmentGradesService.getAssignmentWithGrades(@assignmentId).finally(() ->
      vm.loading = false
    )
  ]

  {
    scope:
      assignmentId: '@'
      formAction: '@'
      formCancelRoute: '@'
      authenticityToken: '@'
    bindToController: true,
    controller: MassEditFormCtrl,
    controllerAs: 'vm',
    templateUrl: 'assignments/grades/mass_edit_form.html'
  }
]
