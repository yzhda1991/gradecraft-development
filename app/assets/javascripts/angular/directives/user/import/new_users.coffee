# Main entry point for rendering new users when importing from an LMS
@gradecraft.directive 'newUsers', ['CanvasImporterService', (CanvasImporterService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/import/new_users.html'
    link: (scope, element, attr) ->
      scope.hasSelectedUsers = CanvasImporterService.hasSelectedUsers

      scope.newUsers = () ->
        _.filter(CanvasImporterService.users, (user) ->
          user.user_exists is false
        )

      scope.termForUserExists = (value) ->
        if value is true then "Yes" else "No"

      scope.selectNewUsers = () ->
        CanvasImporterService.setUsersSelected(true, @newUsers())

      scope.deselectNewUsers = () ->
        CanvasImporterService.setUsersSelected(false, @newUsers())
  }
]
