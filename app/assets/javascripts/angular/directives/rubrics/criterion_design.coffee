# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricCriterionDesign', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/criterion_design.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->
      scope.createCriterion = ()->
        console.log("createCriterion");
      scope.criterionIsSaved = ()->
        console.log("criterionIsSaved");
      scope.createLevel = ()->
        console.log("createLevel");
      scope.criterionIsNew = ()->
        console.log("criterionIsNew");
      scope.insertLevel = (criterion)->
        console.log("insertLevel");
      scope.levelIsSaved = ()->
        console.log("levelIsSaved");
  }
]

