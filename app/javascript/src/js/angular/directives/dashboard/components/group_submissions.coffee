@gradecraft.directive "groupSubmissions", [() ->
  {
    scope:
      assignment: "="
    controllerAs: "groupSubmissionsCtrl"
    restrict: "EA"
    templateUrl: "dashboard/components/group_submissions.html"
  }
]
