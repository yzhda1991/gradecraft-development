# Renders container for one level in a criterion

gradecraft.directive 'rubricLevel', ['RubricService', (RubricService) ->

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
        return "Meets Expectations" if scope.isMeetsExpectationsLevel()
        return "Set As 'Meets Expectations'"

      scope.expectationsHoverLabel = ()->
        return "Set As 'Meets Expectations'" if @level.full_credit
        return "Remove 'Meets Expectations'" if scope.isMeetsExpectationsLevel()
        return "Set As 'Meets Expectations'"

      #--------------------- CRUD ---------------------------------------------#

      scope.queueUpdateLevel = ()->
        if scope.levelIsSaved()
          RubricService.queueUpdateLevel(@level)
        else if scope.requirementsMet()
          RubricService.saveNewLevel(@level)

      scope.deleteLevel = ()->
        if scope.levelIsSaved()
           RubricService.deleteLevel(@level)
        else
          RubricService.removeNewLevel(@level)

      #--------------------- NEW LEVELS ---------------------------------------#

      scope.levelIsSaved = ()->
        !@level.newLevel

      scope.requirements = ()->
        reqs = []
        if !@level.name || @level.name.length < 1
          reqs.push "The level must have a name"
        if @level.points == null
          reqs.push "The level must have points assigned"
        return reqs

      scope.requirementsMet = ()->
        scope.requirements().length == 0
  }
]
