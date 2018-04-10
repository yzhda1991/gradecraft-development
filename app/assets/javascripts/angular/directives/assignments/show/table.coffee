@gradecraft.directive "assignmentShowTable", ["AssignmentService", "AssignmentTypeService", "StudentService", "GradeReleaseService", "$q",
  (AssignmentService, AssignmentTypeService, StudentService, GradeReleaseService, $q) ->
    AssignmentShowTableCtrl = [() ->
      vm = this
      vm.loading = true

      vm.hasSelectedGrades = () -> _.some(GradeReleaseService.gradeIds)
      vm.hasUnreleasedGrades = () -> _.some(StudentService.students, (student) -> student.grade_id? and student.grade_not_released is true)

      vm.releaseGrades = () ->
        return unless vm.hasSelectedGrades()
        GradeReleaseService.postReleaseGrades(@assignmentId).then(
          () ->
            alert("#{GradeReleaseService.gradeIds.length} grade(s) successfully released")
            GradeReleaseService.clearGradeIds()
            StudentService.getForAssignment(vm.assignmentId)
          , () ->
            alert("An error occurred while attempting to release #{GradeReleaseService.gradeIds.length} grades")
        )

      services(@assignmentId, @assignmentTypeId).then(() ->
        vm.loading = false
      )
    ]

    services = (assignmentId, assignmentTypeId) ->
      promises = [
        AssignmentService.getAssignment(assignmentId),
        AssignmentTypeService.getAssignmentType(assignmentTypeId)
      ]
      $q.all(promises)

    {
      scope:
        linksVisible: "@"
        assignmentId: "@"
        assignmentTypeId: "@"
      bindToController: true
      controller: AssignmentShowTableCtrl
      controllerAs: "assignmentShowTableCtrl"
      restrict: "EA"
      templateUrl: "assignments/show/table.html"
    }
]
