#= require spec_helper

describe('BadgeCtrl', ()->
  describe('$scope.badges', ()->
    it('loads the badges on init', ()->
      @controller('BadgeCtrl', { $scope: @scope })
      expect(@scope.termFor("badges")).toEqual("Badges")
    )
  )
)
