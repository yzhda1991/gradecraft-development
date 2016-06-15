@gradecraft.controller 'BadgeCtrl', ['$scope', '$q', 'PredictorService', ($scope, $q, PredictorService) ->

  $scope.init = ()->
    $scope.services().then(()->
      console.log('complete')
    )
  $scope.badges = PredictorService.badges
  $scope.termFor = PredictorService.termFor

  $scope.services = ()->
    promises = [PredictorService.getBadges(),]
    return $q.all(promises)

  $scope.foo = ()->
    console.log('foo')

  return
]
