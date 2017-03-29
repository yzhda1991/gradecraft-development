# Renders the search results from the user search form
@gradecraft.directive 'userSearchResults', ['UserSearchService', (UserSearchService) ->
  {
    restrict: 'EA'
    templateUrl: 'user/search/results.html'
    link: (scope, element, attr) ->
      scope.users = UserSearchService.users

      scope.course_membership_attribute_for = (user, attribute) ->
        _.pluck(user.course_memberships, attribute).join("<br>")
  }
]
