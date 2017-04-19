# Main entry point for LMS user import form
@gradecraft.directive 'userImportForm', ['UserImportService', (UserImportService) ->
  UserImportFormCtrl = [() ->
    vm = this

    vm.loading = true
    vm.options = undefined

    vm.termForUserExists = (value) ->
      if value is true then "Yes" else "No"

    vm.selectAllUsers = () ->
      UserImportService.setUsersSelected(true)

    vm.deselectAllUsers = () ->
      UserImportService.setUsersSelected(false)

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
