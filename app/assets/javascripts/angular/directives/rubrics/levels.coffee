# Iterates through levels in a criterion

@gradecraft.directive 'rubricCriterionLevels', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/levels.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.criterionLevels = ()->
        RubricService.criterionLevels(@criterion)

      scope.levelIsSaved = (level)->
        level.id != undefined

      scope.criterionIsSaved = ()->
        @criterion.id != undefined

      scope.meetsExpectationSet = ()->
        RubricService.meetsExpectationSet(@criterion)

      scope.satifiesExpectations = (level)->
        RubricService.satifiesExpectations(@criterion, level)

      scope.addLevel = ()->
        RubricService.addLevel(@criterion)

      scope.newLevels = ()->
        _.filter(RubricService.newLevels, {criterion_id: @criterion.id})

      scope.openNewLevel = ()->
        RubricService.openNewLevel(@criterion)

      scope.canAddNewLevel = ()->
        _.filter(RubricService.newLevels, {criterion_id : @criterion.id}).length == 0

  }
]
