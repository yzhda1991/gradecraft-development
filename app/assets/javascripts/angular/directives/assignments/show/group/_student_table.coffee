@gradecraft.directive "assignmentShowGroupStudentTable", ["AssignmentGradesService", "AssignmentService", "AssignmentTypeService", "GradeReleaseService",
  (AssignmentGradesService, AssignmentService, AssignmentTypeService, GradeReleaseService) ->
    AssignmentShowGroupStudentTableCtrl = [() ->
      vm = this
      vm.assignment = AssignmentService.assignment
      vm.assignmentType = AssignmentTypeService.assignmentType
      vm.students = AssignmentGradesService.students

      vm.gradesToRelease = GradeReleaseService.gradeIds
      vm.toggleGradeSelection = (gradeId) -> GradeReleaseService.toggleGradeSelection(gradeId)

      vm.loading = () -> !AssignmentTypeService.assignmentType()?

      vm.gradesForGroup = () -> AssignmentGradesService.gradesForGroup(@group)
      vm.termFor = (term) -> AssignmentGradesService.termFor(term)

      vm.showPassFailStatus = (grade) -> vm.assignment().pass_fail && grade.pass_fail_status?

      # Select or deselect all grades
      vm.selectGrades = (selectAll) ->
        GradeReleaseService.clearGradeIds()
        return if selectAll is false
        gradeIds = _pluckGradedIdsForRelease(vm.gradesForGroup())
        GradeReleaseService.addGradeIds(gradeIds...)
    ]

    _pluckGradedIdsForRelease = (grades) ->
      gradeIds = []
      (gradeIds.push(grade.id) if grade.graded and grade.not_released is true) for grade in grades
      gradeIds

    {
      scope:
        group: "="
      restrict: "A"
      bindToController: true
      controller: AssignmentShowGroupStudentTableCtrl
      controllerAs: "groupStudentTableCtrl"
      templateUrl: "assignments/show/group/_student_table.html"
    }
]
