# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricCriterionLevels', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/levels.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.levelIsSaved = (level)->
        level.id != undefined

      scope.meetsExpectationSet = (criterion)->
        RubricService.meetsExpectationSet(criterion)

      scope.satifiesExpectations = (level)->
        RubricService.satifiesExpectations(@criterion, level)

  }
]





# level.change()
# level.editBadges()
# level.selectBadge()
# level.closeBadges()



