# A table of assignments with editable settings
@gradecraft.directive 'assignmentsSettingsTable', ['$q', 'AssignmentTypeService', 'AssignmentService', 'GradeSchemeElementsService', ($q, AssignmentTypeService, AssignmentService, GradeSchemeElementsService) ->
  AssignmentsSettingsCtrl = [()->
    vm = this
    vm.loading = true
    vm.assignmentTypes = AssignmentTypeService.assignmentTypes
    vm.GradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements
    vm.assignments = AssignmentService.assignments

    vm.updateAssignment = (id)->
      AssignmentService.queueUpdateAssignment(id)

    vm.termFor = (term)->
      AssignmentService.termFor(term)

    services().then(()->
      vm.loading = false
      vm.totalPoints = GradeSchemeElementsService.totalPoints()
    )
  ]

  services = ()->
    promises = [
      AssignmentService.getAssignments(),
      AssignmentTypeService.getAssignmentTypes(),
      GradeSchemeElementsService.getGradeSchemeElements()
    ]
    return $q.all(promises)

  {
    bindToController: true,
    controller: AssignmentsSettingsCtrl,
    controllerAs: 'vm',
    templateUrl: 'assignments/settings_table.html',
  }
]
