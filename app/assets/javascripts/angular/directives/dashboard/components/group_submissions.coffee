@gradecraft.directive "groupSubmissions", [() ->
  {
    scope:
      assignments: "="
    controllerAs: "groupSubmissionsCtrl"
    restrict: "EA"
    templateUrl: "dashboard/components/group_submissions.html"
  }
]
