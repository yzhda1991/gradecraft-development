@gradecraft.directive "gradingStatusInProgressGrades", ["GradingStatusService", "$sce", (GradingStatusService, $sce) ->
  GradingStatusInProgressGradesCtrl = [() ->
    vm = this
    vm.loading = true
    vm.grades = GradingStatusService.inProgressGrades

    vm.sanitize = (html) -> $sce.trustAsHtml(html)

    vm.releaseGrades = () -> confirm("Release Selected Grades to Students?")

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
