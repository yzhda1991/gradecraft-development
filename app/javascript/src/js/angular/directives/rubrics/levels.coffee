# Iterates through levels in a criterion

gradecraft.directive 'rubricCriterionLevels', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/levels.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.criterionLevels = ()->
        RubricService.criterionLevels(@criterion)

      scope.levelIsSaved = (level)->
        !@level.newLevel

      scope.criterionIsSaved = ()->
        !@criterion.newCriterion

      scope.meetsExpectationSet = ()->
        RubricService.meetsExpectationSet(@criterion)

      scope.satifiesExpectations = (level)->
        RubricService.satifiesExpectations(@criterion, level)

      scope.addLevel = ()->
        RubricService.addLevel(@criterion)

      scope.openNewLevel = ()->
        RubricService.openNewLevel(@criterion)

      scope.canAddNewLevel = ()->
        _.filter(RubricService.levels, {newLevel: true, criterion_id : @criterion.id}).length == 0

  }
]
