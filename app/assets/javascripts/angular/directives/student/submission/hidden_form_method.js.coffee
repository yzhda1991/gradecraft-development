@gradecraft.directive 'hiddenFormMethod', ['StudentSubmissionService', (StudentSubmissionService) ->
  HiddenFormMethodCtrl = ['$scope', ($scope) ->
    vm = this
    vm.submission = StudentSubmissionService.getSubmission()
    vm.formMethod = null

    $scope.$watch(() ->
      vm.submission
    , (newValue, oldValue) ->
      vm.formMethod = if newValue? and newValue.id? then "patch" else null
    , true)
  ]

  {
    replace: true,
    restrict: 'EA',
    bindToController: true,
    controller: HiddenFormMethodCtrl,
    controllerAs: 'vm',
    templateUrl: 'student/submission/hidden_form_method.html'
  }
]
