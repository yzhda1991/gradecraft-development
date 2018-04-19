@gradecraft.directive "assignmentShowGroupTable", ['AssignmentGradesService', "GradeReleaseService",
  (AssignmentGradesService, GradeReleaseService) ->
    AssignmentShowGroupTableCtrl = [() ->
      vm = this
      vm.hasSelectedGrades = GradeReleaseService.hasSelectedGrades

      vm.termFor = (term) -> AssignmentGradesService.termFor(term)
      vm.releaseGrades = () -> GradeReleaseService.postReleaseGrades(@assignmentId)

      vm.hasUnreleasedGrades = () -> _.some(AssignmentGradesService.groupGrades,
        (grade) -> grade.graded and grade.not_released is true
      )
    ]

    {
      scope:
        linksVisible: "@"
        assignmentId: "@"
      bindToController: true
      controller: AssignmentShowGroupTableCtrl
      controllerAs: "groupTableCtrl"
      templateUrl: "assignments/show/group/table.html"
    }
]
