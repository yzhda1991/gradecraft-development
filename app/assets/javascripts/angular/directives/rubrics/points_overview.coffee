# Hovering synopsis of the rubric points assigned

@gradecraft.directive 'rubricPointsOverview', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/points_overview.html'
    link: (scope, el, attr)->
      scope.pointsAssigned = ()->
        console.log("pointsAssigned");
        return 100
      scope.pointsMeetExpectations = ()->
        console.log("pointsMeetExpectations");
        return true
      scope.pointsMissing = ()->
        console.log("pointsMissing");
        return false
      scope.pointsOverage = ()->
        console.log("pointsOverage");
        return 0
      scope.pointsRemaining = ()->
        console.log("pointsRemaining");
        return 0
      scope.pointsSatisfied = ()->
        console.log("pointsSatisfied");
        return true
  }

]

