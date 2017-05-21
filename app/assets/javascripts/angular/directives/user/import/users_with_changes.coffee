# Main entry point for rendering users with revised changes when importing from an LMS
@gradecraft.directive 'usersWithChanges', ['CanvasImporterService', (CanvasImporterService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/import/users_with_changes.html'
    link: (scope, element, attr) ->
      scope.hasSelectedUsers = CanvasImporterService.hasSelectedUsers

      scope.changedUsers = () ->
        _.filter(CanvasImporterService.users, (user) ->
          user.user_exists is true and user.role_changed is true
        )

      scope.termForUserExists = (value) ->
        if value is true then "Yes" else "No"

      scope.selectChangedUsers = () ->
        CanvasImporterService.setUsersSelected(true, @changedUsers())

      scope.deselectChangedUsers = () ->
        CanvasImporterService.setUsersSelected(false, @changedUsers())
  }
]
