# Controls form action attribute on a hidden input field based on changes to submission
# Required for Rails since most browsers don't support PUT
# See http://guides.rubyonrails.org/form_helpers.html#how-do-forms-with-patch-put-or-delete-methods-work-questionmark
gradecraft.directive 'hiddenFormMethod', ['StudentSubmissionService', (StudentSubmissionService) ->
  HiddenFormMethodCtrl = ['$scope', ($scope) ->
    vm = this
    vm.submission = StudentSubmissionService.submission
    vm.formMethod = null

    $scope.$watch(() ->
      vm.submission
    , (newValue, oldValue) ->
      vm.formMethod = if newValue? and newValue.id? then "patch" else null
    , true)
  ]

  {
    restrict: 'EA'
    bindToController: true
    controller: HiddenFormMethodCtrl
    controllerAs: 'vm'
    templateUrl: 'student/submission/hidden_form_method.html'
  }
]
