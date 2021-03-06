@gradecraft.directive "assignmentShowIndividualTable", ["AssignmentService", "AssignmentTypeService", "StudentService", "GradeReleaseService", "SortableService", "$q",
  (AssignmentService, AssignmentTypeService, StudentService, GradeReleaseService, SortableService, $q) ->
    AssignmentShowIndividualTableCtrl = [() ->
      vm = this
      vm.loading = true
      vm.searchCriteria = SortableService.filterCriteria
      vm.hasSelectedGrades = GradeReleaseService.hasSelectedGrades

      vm.hasUnreleasedGrades = () -> _.some(StudentService.students, (student) -> student.grade_id? and student.grade_not_released is true)

      vm.releaseGrades = () ->
        return unless vm.hasSelectedGrades()
        GradeReleaseService.postRelease(
          () ->
            alert("#{GradeReleaseService.gradeIds.length} grade(s) successfully released")
            # Refresh the list of students with new release statuses
            GradeReleaseService.clearGradeIds()
            StudentService.clearStudents()
            StudentService.getBatchedForAssignment(vm.assignmentId)
          , () ->
            alert("An error occurred while attempting to release #{GradeReleaseService.gradeIds.length} grades")
        )

      services(@assignmentId, @assignmentTypeId).then(() -> vm.loading = false)
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
      controller: AssignmentShowIndividualTableCtrl
      controllerAs: "individualTableCtrl"
      restrict: "EA"
      templateUrl: "assignments/show/individual/table.html"
    }
]
