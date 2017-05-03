# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricLevelDesign', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/level_design.html'
    scope: {
      criterion: "="
      level: "="
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

