# This directive manages loading the assignments once for the assignments settings page
@gradecraft.directive 'assignmentsSettingsTable', ['$q', 'AssignmentTypeService', 'AssignmentService', 'GradeSchemeElementsService', ($q, AssignmentTypeService, AssignmentService, GradeSchemeElementsService) ->
  AssignmentsSettingsCtrl = [()->
    vm = this
    vm.loading = true
    vm.assignmentTypes = AssignmentTypeService.assignmentTypes
    vm.GradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements

    vm.termFor = (term)->
      AssignmentService.termFor(term)

    # ================ methods for Assignment Types ============================

    vm.pointsOver = (assignmentType)->
      assignmentType.total_points > vm.totalPoints

    vm.pointsGraphStyle = (assignmentType)->
      if vm.pointsOver(assignmentType)
        "width: 100%; background-color: #D1495B"
      else
        "width: #{(assignmentType.total_points / vm.totalPoints * 100) }%"

    vm.pointsGraphPercentOfTotal = (gradeSchemeElement)->
      (gradeSchemeElement.lowest_points / vm.totalPoints * 100) + "%"

    # ==========================================================================

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
