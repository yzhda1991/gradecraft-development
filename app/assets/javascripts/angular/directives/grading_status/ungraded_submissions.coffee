@gradecraft.directive "gradingStatusUngradedSubmissions", ["GradingStatusSubmissionsService", "$sce",
  (GradingStatusSubmissionsService, $sce) ->
    GradingStatusUngradedSubmissionsCtrl = [() ->
      vm = this
      vm.loading = true
      vm.submissions = GradingStatusSubmissionsService.ungraded

      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.showSeeGradeBtn = (submission) ->
        submission.individual_assignment and submission.grade_path?

      vm.showEditGradeBtn = (submission) -> @linksVisible and vm.showSeeGradeBtn(submission)

      vm.showCreateGradeBtn = (submission) ->
        @linksVisible and submission.individual_assignment and not submission.grade_path?

      vm.showGroupGradeBtn = (submission) ->
        @linksVisible and !submission.individual_assignment

      vm.createGrade = (submission) -> console.warn ("Not yet implemented")

      GradingStatusSubmissionsService.getUngraded().then(() -> vm.loading = false)
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
