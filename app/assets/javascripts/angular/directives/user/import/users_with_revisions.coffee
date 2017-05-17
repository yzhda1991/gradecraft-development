# Main entry point for rendering users with revised changes when importing from an LMS
@gradecraft.directive 'usersWithChanges', ['UserImporterService', (UserImporterService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/import/users_with_changes.html'
    link: (scope, element, attr) ->
      scope.changedUsers = UserImporterService.changedUsers()

      scope.selectChangedUsers = () ->
        UserImporterService.setUsersSelected(true, UserImporterService.changedUsers())

      scope.deselectChangedUsers = () ->
        UserImporterService.setUsersSelected(false, UserImporterService.changedUsers())
  }
]
