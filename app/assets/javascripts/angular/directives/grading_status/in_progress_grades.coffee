@gradecraft.directive "gradingStatusInProgressGrades", ["GradingStatusService", "GradeReleaseService", "$q", "$sce",
  (GradingStatusService, GradeReleaseService, $q, $sce) ->
    GradingStatusInProgressGradesCtrl = [() ->
      vm = this
      vm.loading = true
      vm.grades = GradingStatusService.inProgressGrades

      vm.gradesToRelease = GradeReleaseService.gradeIds
      vm.hasSelectedGrades = GradeReleaseService.hasSelectedGrades

      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.toggleGradeSelection = (gradeId) -> GradeReleaseService.toggleGradeSelection(gradeId)

      vm.selectGrades = (select) ->
        gradeIds = _.pluck(vm.grades, "id")
        GradeReleaseService.clearGradeIds()
        GradeReleaseService.addGradeIds(gradeIds...) if select is true

      vm.releaseGrades = () ->
        return unless GradeReleaseService.hasSelectedGrades()
        GradeReleaseService.postRelease().then(
          () ->
            alert("#{GradeReleaseService.gradeIds.length} grade(s) successfully released")
            GradeReleaseService.clearGradeIds()
            GradingStatusService.getInProgressGrades(true)
          , () ->
            alert("An unexpected error occurred while attempting to release grades")
        )

      GradingStatusService.getInProgressGrades().then(() -> vm.loading = false)
    ]

    {
      scope:
        courseHasTeams: "@"
        assignmentTerm: "@"
        teamTerm: "@"
        linksVisible: "@"
      bindToController: true
      controller: GradingStatusInProgressGradesCtrl
      controllerAs: "gsInProgressGradesCtrl"
      templateUrl: "grading_status/in_progress_grades.html"
    }
]
