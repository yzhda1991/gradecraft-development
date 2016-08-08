@gradecraft.controller 'BadgeCtrl', ['$scope', '$q', 'BadgeService', 'StudentPanelService', ($scope, $q, BadgeService, StudentPanelService) ->

  $scope.init = ()->
    $scope.services().then(()->
      StudentPanelService.changeFocusArticle($scope.badges[0])
    )
  $scope.badges = BadgeService.badges
  $scope.termFor = BadgeService.termFor

  $scope.services = ()->
    promises = [BadgeService.getBadges(),]
    return $q.all(promises)

  $scope.changeFocusArticle = (article)->
    StudentPanelService.changeFocusArticle(article)

  return
]
