@gradecraft.directive "gradingStatusUngradedSubmissions", ["GradingStatusService", "$sce",
  (GradingStatusService, $sce) ->
    GradingStatusUngradedSubmissionsCtrl = [() ->
      vm = this
      vm.loading = true
      vm.submissions = GradingStatusService.ungradedSubmissions

      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.showSeeGradeBtn = (submission) ->
        submission.individual_assignment and submission.grade_path?

      vm.showEditGradeBtn = (submission) -> @linksVisible and vm.showSeeGradeBtn(submission)

      vm.showCreateGradeBtn = (submission) ->
        @linksVisible and submission.individual_assignment and not submission.grade_path?

      vm.showGroupGradeBtn = (submission) ->
        @linksVisible and !submission.individual_assignment

      GradingStatusService.getUngradedSubmissions().then(() -> vm.loading = false)
    ]

    {
      scope:
        courseHasTeams: "@"
        assignmentTerm: "@"
        teamTerm: "@"
        linksVisible: "@"
      bindToController: true
      controller: GradingStatusUngradedSubmissionsCtrl
      controllerAs: "gsUngradedCtrl"
      templateUrl: "grading_status/ungraded_submissions.html"
    }
]
