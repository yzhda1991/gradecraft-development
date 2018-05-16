# Renders grades component for grading status page
# Shared directive which takes a type of grade
#   Allowable types: [InProgress, ReadyForRelease]
@gradecraft.directive "gradingStatusGrades", ["GradingStatusService", "GradeReleaseService", "SortableService", "$q", "$sce",
  (GradingStatusService, GradeReleaseService, SortableService, $q, $sce) ->
    GradingStatusGradesCtrl = [() ->
      vm = this
      vm.loading = true
      vm.sortable = SortableService
      vm.grades = GradingStatusService["#{_lowerFirst(@type)}Grades"]

      vm.gradesToRelease = GradeReleaseService.gradeIds
      vm.hasSelectedGrades = GradeReleaseService.hasSelectedGrades

      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.toggleGradeSelection = (gradeId) -> GradeReleaseService.toggleGradeSelection(gradeId)

      vm.selectGrades = (select) ->
        gradeIds = _.pluck(vm.grades, "id")
        GradeReleaseService.clearGradeIds(gradeIds...)
        GradeReleaseService.addGradeIds(gradeIds...) if select is true

      vm.releaseGrades = () ->
        return unless GradeReleaseService.hasSelectedGrades()
        GradeReleaseService.postRelease().then(
          () ->
            alert("#{GradeReleaseService.gradeIds.length} grade(s) successfully released")
            GradeReleaseService.clearGradeIds()
            GradingStatusService["get#{vm.type}Grades"](true)
          , () ->
            alert("An unexpected error occurred while attempting to release grades")
        )

      GradingStatusService["get#{@type}Grades"]().then(() -> vm.loading = false)
    ]

    _lowerFirst = (str) -> str.charAt(0).toLowerCase() + str.slice(1)

    {
      scope:
        type: "@"
        courseHasTeams: "@"
        assignmentTerm: "@"
        teamTerm: "@"
        linksVisible: "@"
      bindToController: true
      controller: GradingStatusGradesCtrl
      controllerAs: "gsGradesCtrl"
      templateUrl: "grading_status/grades.html"
    }
]
