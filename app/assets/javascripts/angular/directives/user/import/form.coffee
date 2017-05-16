# Main entry point for LMS user import form
@gradecraft.directive 'userImportForm', ['UserImporterService', (UserImporterService) ->
  UserImportFormCtrl = [() ->
    vm = this

    vm.loading = true
    vm.formSubmitted = false
    vm.options = undefined

    vm.formAction = "/users/importers/#{@provider}/course/#{@courseId}/users/import"

    vm.termForUserExists = (value) ->
      if value is true then "Yes" else "No"

    vm.hasSelectedGrades = () ->
      _.any(UserImporterService.users, (user) ->
        user.selected_for_import is true
      )

    vm.hasError = () ->
      UserImporterService.checkHasError()

    initialize(@provider, @courseId, vm.options).then(() ->
      vm.loading = false
    )
  ]

  initialize = (provider, courseId) ->
    UserImporterService.getUsers(provider, courseId)

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
      scope.users = UserImporterService.users
  }
]
