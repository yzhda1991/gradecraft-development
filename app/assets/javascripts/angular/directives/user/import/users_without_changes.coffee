# Main entry point for rendering users without changes when importing from an LMS
@gradecraft.directive 'usersWithoutChanges', ['CanvasImporterService', (CanvasImporterService) ->
  UsersWithoutChangesCtrl = [() ->
    vm = this
    vm.showInfo = false
  ]

  {
    bindToController: true
    controller: UsersWithoutChangesCtrl
    controllerAs: 'ctrl'
    restrict: 'EA'
    templateUrl: 'user/import/users_without_changes.html'
    link: (scope, element, attr) ->
      scope.unchangedUsers = () ->
        _.filter(CanvasImporterService.users, (user) ->
          user.user_exists is true and user.role_changed is false
        )
  }
]
