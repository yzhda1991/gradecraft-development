# Main entry point for the user search utility
@gradecraft.directive 'userSearchUtility', ['UserSearchService', (UserSearchService) ->
  UserSearchCtrl = [() ->
    vm = this

    vm.loading = false
    vm.searchTypes = ['Name', 'Email', 'Username']
    vm.selectedSearchType = vm.searchTypes[0]

    vm.getSearchResults = () ->
      vm.loading = true
      UserSearchService.getSearchResults(vm.selectedSearchType).then(() ->
        vm.loading = false
      )
  ]

  {
    bindToController: true
    controller: UserSearchCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'user/search/main.html'
    link: (scope, element, attr) ->
      scope.users = UserSearchService.users
      scope.searchCriteria = UserSearchService.searchCriteria
  }
]
