# Renders container for one criterion in a rubric

@gradecraft.directive 'rubricCriterion', ['RubricService', (RubricService) ->

  return {
    templateUrl: 'rubrics/criterion.html'
    scope: {
      criterion: "="
    }
    link: (scope, el, attr)->

      scope.queueUpdateCriterion = ()->
        if scope.criterionIsSaved()
          RubricService.queueUpdateCriterion(@criterion)
        else if scope.requirementsMet()
          RubricService.saveNewCriterion(@criterion)


      scope.deleteCriterion = ()->
        RubricService.deleteCriterion(@criterion)

      #--------------------- NEW LEVELS ---------------------------------------#

      scope.criterionIsSaved = ()->
        @criterion.id != undefined

      scope.requirements = ()->
        reqs = []
        if !@criterion.name || @criterion.name.length < 1
          reqs.push "The criterion must have a name"
        if @criterion.max_points == null
          reqs.push "The criterion must have max points assigned"
        return reqs

      scope.requirementsMet = ()->
        scope.requirements().length == 0

  }
]

