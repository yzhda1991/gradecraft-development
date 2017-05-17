# Main entry point for rendering users without changes when importing from an LMS
@gradecraft.directive 'usersWithoutChanges', ['UserImporterService', (UserImporterService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/import/users_without_changes.html'
    link: (scope, element, attr) ->
      scope.unchangedUsers = UserImporterService.unchangedUsers()
      scope.showInfo = false
  }
]
