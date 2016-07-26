@gradecraft.controller 'BadgeCtrl', ['$scope', '$q', 'BadgeService', ($scope, $q, BadgeService) ->

  $scope.init = ()->
    $scope.services().then(()->
      console.log('complete')
    )
  $scope.badges = BadgeService.badges
  $scope.termFor = BadgeService.termFor

  $scope.services = ()->
    promises = [BadgeService.getBadges(),]
    return $q.all(promises)

  $scope.foo = ()->
    console.log('foo')

  return
]
