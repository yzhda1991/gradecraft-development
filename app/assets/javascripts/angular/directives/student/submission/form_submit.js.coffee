@gradecraft.directive 'formSubmit', ['StudentSubmissionService', (StudentSubmissionService) ->

  FormSubmitCtrl = ['$scope', ($scope) ->
    $scope.loaded = StudentSubmissionService.getSubmission()?
  ]

  {
    bindToController: true,
    controller: FormSubmitCtrl,
    controllerAs: 'vm',
    restrict: 'C'
  }
]
