# Interactive container for one level in a criterion

@gradecraft.directive 'rubricLevel', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/level.html'
    scope: {
      criterion: "="
      level: "="
    }
    link: (scope, el, attr)->

      scope.availableBadgesForLevel = ()->
        RubricService.availableBadgesForLevel(scope.level)

      #--------------------- meets expectations -------------------------------#

      scope.updateMeetsExpectationsLevel = ()->
        RubricService.updateMeetsExpectationsLevel(@criterion, @level)

      scope.meetsExpectationsSet = ()->
        RubricService.meetsExpectationsSet(@criterion)

      # This is the level that is set for "meets expectations"
      scope.isMeetsExpectationsLevel = ()->
        RubricService.isMeetsExpectationsLevel(@criterion, @level)

      scope.showExpectationButton = ()->
        scope.isMeetsExpectationsLevel() || !scope.meetsExpectationsSet()

      scope.expectationsLabel = ()->
        return "Full Credit Level" if @level.full_credit
        return "Meets Expectations" if scope.isMeetsExpectationsLevel()
        return "Set As 'Meets Expectations'"

      scope.expectationsHoverLabel = ()->
        return "Set As 'Meets Expectations'" if @level.full_credit
        return "Remove 'Meets Expectations'" if scope.isMeetsExpectationsLevel()
        return "Set As 'Meets Expectations'"

      #--------------------- CRUD ---------------------------------------------#

      scope.toggleMeetsExpectations = ()->
        console.log("toggling meets expectations");

      scope.queueUpdateLevel = ()->
        RubricService.queueUpdateLevel(@level)

      scope.deleteLevel = ()->
        RubricService.deleteLevel(@level)
  }
]
