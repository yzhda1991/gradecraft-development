#renders design container for one criterion in a rubric

@gradecraft.directive 'rubricCriterion', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/criterion.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.criterionIsSaved = ()->
        @criterion.id != undefined

      scope.criterionIsNew = ()->
        #console.log("criterionIsNew");

      scope.createCriterion = ()->
        console.log("createCriterion");

      scope.queueUpdateCriterion = ()->
        RubricService.queueUpdateCriterion(@criterion)

      scope.deleteCriterion = ()->
        RubricService.deleteCriterion(@criterion)

  }
]

