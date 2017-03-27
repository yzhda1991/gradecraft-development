# Main entry point for the user search utility
@gradecraft.directive 'userSearchUtility', ['UserSearchService', (UserSearchService) ->
  UserSearchCtrl = [() ->
    vm = this

    vm.users = UserSearchService.users
    vm.loading = false
    vm.firstName = undefined
    vm.lastName = undefined
    vm.email = undefined

    vm.getSearchResults = () ->
      vm.loading = true
      UserSearchService.getSearchResults(vm.firstName, vm.lastName, vm.email).then(() ->
        vm.loading = false
      )
  ]

  {
    bindToController: true
    controller: UserSearchCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'user/search/main.html'
  }
]
