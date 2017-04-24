# Main entry point for LMS user import form
@gradecraft.directive 'userImportForm', ['UserImportService', (UserImportService) ->
  UserImportFormCtrl = [() ->
    vm = this

    vm.loading = true
    vm.formSubmitted = false
    vm.options = undefined

    vm.formAction = "/users/importers/#{@provider}/course/#{@courseId}/users/import"

    vm.termForUserExists = (value) ->
      if value is true then "Yes" else "No"

    vm.selectAllUsers = () ->
      UserImportService.setUsersSelected(true)

    vm.deselectAllUsers = () ->
      UserImportService.setUsersSelected(false)

    vm.hasSelectedGrades = () ->
      _.any(UserImportService.users, (user) ->
        user.selected_for_import is true
      )

    initialize(@provider, @courseId, vm.options).then(() ->
      vm.loading = false
    )
  ]

  initialize = (provider, courseId) ->
    UserImportService.getUsers(provider, courseId)

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
    link: (scope, element, attr) ->
      scope.users = UserImportService.users
      scope.hasError = UserImportService.hasError
  }
]
