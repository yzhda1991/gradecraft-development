# A table of assignments with editable grades
@gradecraft.directive 'massEditForm', ['AssignmentGradesService', 'TeamService', (AssignmentGradesService, TeamService) ->
  MassEditFormCtrl = ['$scope', ($scope)->
    vm = this
    vm.loading = true

    vm.assignmentScoreLevels = AssignmentGradesService.assignmentScoreLevels
    vm.assignment = AssignmentGradesService.assignment
    vm.grades = AssignmentGradesService.grades
    vm.termFor = AssignmentGradesService.termFor
    vm.selectedGradingStyle = AssignmentGradesService.selectedGradingStyle
    vm.selectedTeamId = TeamService.selectedTeamId

    vm.getAssignmentWithGrades = () ->
      vm.loading = true
      AssignmentGradesService.getAssignmentWithGrades(vm.assignmentId, vm.selectedTeamId())

    # Update listed grades on the form whenever the value of the selected team id
    # changes on the TeamService
    $scope.$watch(() ->
      vm.selectedTeamId()
    , (newValue, oldValue) ->
      return if newValue == oldValue
      vm.getAssignmentWithGrades().finally(() ->
        vm.loading = false
      )
    )

    vm.getAssignmentWithGrades().finally(() ->
      vm.loading = false
      AssignmentGradesService.setDefaultGradingStyle()
    )
  ]

  {
    scope:
      assignmentId: '@'
      formAction: '@'
      formCancelRoute: '@'
      authenticityToken: '@'
    bindToController: true
    controller: MassEditFormCtrl
    controllerAs: 'vm'
    templateUrl: 'assignments/grades/mass_edit_form.html'
  }
]
