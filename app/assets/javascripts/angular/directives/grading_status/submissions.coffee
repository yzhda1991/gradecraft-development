@gradecraft.directive 'gradingStatusSubmissions', [() ->
  GradingStatusSubmissionsCtrl = [() ->
    vm = this
    vm.loading = true

    
  ]

  {
    scope:
      submissions: '='
    bindToController: true
    controller: GradingStatusSubmissionsCtrl
    controllerAs: 'gsSubmissionsCtrl'
    templateUrl: 'grading_status/submissions.html'
  }
]
