# A table of assignments with editable group grades
@gradecraft.directive 'groupMassEditForm', ['AssignmentGradesService', (AssignmentGradesService) ->
  GroupMassEditFormCtrl = [()->
    vm = this
    vm.loading = true

    vm.assignment = AssignmentGradesService.assignment
    vm.assignmentScoreLevels = AssignmentGradesService.assignmentScoreLevels
    vm.groupGrades = AssignmentGradesService.groupGrades
    vm.selectedGradingStyle = AssignmentGradesService.selectedGradingStyle
    vm.termFor = AssignmentGradesService.termFor

    AssignmentGradesService.getGroupAssignmentWithGrades(@assignmentId).finally(() ->
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
      termForGroups: '@'
    bindToController: true
    controller: GroupMassEditFormCtrl
    controllerAs: 'vm'
    templateUrl: 'assignments/groups/grades/mass_edit_form.html'
  }
]
