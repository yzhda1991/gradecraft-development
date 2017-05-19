# Main entry point for LMS user import form
@gradecraft.directive 'userImportForm', ['CanvasImporterService', (CanvasImporterService) ->
  UserImportFormCtrl = ['$scope', ($scope) ->
    vm = this

    vm.hasError = false
    vm.formSubmitted = false
    vm.users = CanvasImporterService.users

    vm.formAction = "/users/importers/#{@provider}/course/#{@courseId}/users/import"

    vm.currentCourseId = CanvasImporterService.currentCourseId

    vm.termForUserExists = (value) ->
      if value is true then "Yes" else "No"

    vm.hasSelectedGrades = () ->
      _.any(CanvasImporterService.users, (user) ->
        user.selected_for_import is true
      )

    vm.getUsers = () ->
      CanvasImporterService.getUsers(vm.provider, vm.currentCourseId()).then((success) ->
        vm.hasError = false
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
      courseId: '@'
      authenticityToken: '@'  # for the form submit
    bindToController: true
    controller: UserImportFormCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'user/import/form.html'
  }
]
