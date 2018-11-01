# Main entry point for LMS user import form
gradecraft.directive 'userImportForm', ['CanvasImporterService', (CanvasImporterService) ->
  UserImportFormCtrl = ['$scope', ($scope) ->
    vm = this
    vm.hasError = false
    vm.loading = undefined
    vm.formSubmitted = false

    vm.users = CanvasImporterService.users
    vm.currentCourseId = CanvasImporterService.currentCourseId

    vm.formAction = () ->
      "/users/importers/#{@provider}/course/#{vm.currentCourseId()}/users/import"

    vm.getUsers = () ->
      vm.loading = true
      CanvasImporterService.getUsers(vm.provider, vm.currentCourseId(), true).then((success) ->
        vm.hasError = false
        vm.loading = false
      , (error) ->
        vm.hasError = true
      )

    # The service keeps track of the current Canvas course context;
    # when the course changes, we should fetch the new set of assignments
    $scope.$watch(() ->
      vm.currentCourseId()
    , (newValue, oldValue) ->
      vm.getUsers() if newValue
    )
  ]

  {
    scope:
      provider: '@'
      authenticityToken: '@'  # for the form submit
    bindToController: true
    controller: UserImportFormCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'user/import/form.html'
  }
]
