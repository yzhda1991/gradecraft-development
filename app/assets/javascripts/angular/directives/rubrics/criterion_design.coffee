# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricCriterionDesign', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/criterion_design.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->
      scope.criterionIsSaved = ()->
        @criterion.id != undefined

      scope.createCriterion = ()->
        console.log("createCriterion");
      scope.createLevel = ()->
        console.log("createLevel");
      scope.criterionIsNew = ()->
        #console.log("criterionIsNew");

      scope.insertLevel = ()->
        console.log("inserting level into criterrion #{@criterion.id}");
  }
]

