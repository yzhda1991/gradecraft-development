# Iterates through levels in a criterion

@gradecraft.directive 'rubricCriterionLevels', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/levels.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.levelIsSaved = (level)->
        level.id != undefined

      scope.criterionIsSaved = ()->
        @criterion.id != undefined

      scope.meetsExpectationSet = (criterion)->
        RubricService.meetsExpectationSet(criterion)

      scope.satifiesExpectations = (level)->
        RubricService.satifiesExpectations(@criterion, level)

      scope.addLevel = ()->
        RubricService.addLevel(@criterion)

      scope.newLevels = ()->
        _.filter(RubricService.newLevels, {criterion_id: @criterion.id})

      scope.addNewLevel = ()->
        RubricService.addNewLevel(@criterion)

      scope.canAddNewLevel = ()->
        _.filter(RubricService.newLevels, {criterion_id : @criterion.id}).length == 0

  }
]
