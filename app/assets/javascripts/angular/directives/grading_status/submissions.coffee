# Renders submissions component for grading status page
# Shared directive which takes a type of submission
#   Allowable types: [Resubmitted, Ungraded]
@gradecraft.directive "gradingStatusSubmissions", ["GradingStatusService", "SortableService", "$sce",
  (GradingStatusService, SortableService, $sce) ->
    GradingStatusSubmissionsCtrl = [() ->
      vm = this
      vm.loading = true
      vm.sortable = SortableService
      vm.searchCriteria = SortableService.filterCriteria

      vm.submissions = GradingStatusService["#{_lowerFirst(@type)}Submissions"]
      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.showTeamLink = (submission) -> submission.team_path? and submission.team_name?
      vm.showSeeGradeBtn = (submission) -> submission.individual_assignment and submission.grade_path?
      vm.showEditGradeBtn = (submission) -> @linksVisible and vm.showSeeGradeBtn(submission)
      vm.showCreateGradeBtn = (submission) -> @linksVisible and submission.individual_assignment and not submission.grade_path?
      vm.showGroupGradeBtn = (submission) -> @linksVisible and !submission.individual_assignment

      GradingStatusService["get#{@type}Submissions"]().then(() -> vm.loading = false)
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
      controller: GradingStatusSubmissionsCtrl
      controllerAs: "gsSubmissionsCtrl"
      templateUrl: "grading_status/submissions.html"
    }
]
