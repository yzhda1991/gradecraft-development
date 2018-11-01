# Interactive container for one level in a criterion

gradecraft.directive 'rubricNewLevel', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/new_level.html'
    scope: {
      criterion: "="
      level: "="
    }
    link: (scope, el, attr)->

      scope.requirements = ()->
        reqs = []
        if !@level.name || @level.name.length < 1
          reqs.push "The level must have a name"
        if @level.points == null
          reqs.push "The level must have points assigned"
        return reqs

      scope.requirementsMet = ()->
        scope.requirements().length == 0

      scope.removeNewLevel = ()->
        RubricService.removeNewLevel(@level)

      scope.saveNewLevel = ()->
        if scope.requirementsMet()
          RubricService.saveNewLevel(@level)
  }
]
