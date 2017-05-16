# Main entry point for rendering new users when importing from an LMS
@gradecraft.directive 'newUsers', ['UserImporterService', (UserImporterService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/import/new_users.html'
    link: (scope, element, attr) ->
      scope.newUsers = UserImporterService.newUsers()

      scope.selectNewUsers = () ->
        UserImporterService.setUsersSelected(true, UserImporterService.newUsers())

      scope.deselectNewUsers = () ->
        UserImporterService.setUsersSelected(false, UserImporterService.newUsers())
  }
]
