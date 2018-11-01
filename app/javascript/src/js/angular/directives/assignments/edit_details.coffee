gradecraft.directive 'assignmentEditDetails', ['AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', (AssignmentTypeService, AssignmentService, LearningObjectivesService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/edit_details.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor
      scope.learningObjectives = LearningObjectivesService.objectives
      scope.isGroupGraded = () -> AssignmentService.isGroupGraded(@assignment)

      scope.hasLearningObjectives = () -> _.some(scope.learningObjectives())

      scope.categoryLabel = (category) ->
        "-- #{category} --" if category?

      scope.toggleObjectiveSelection = (objectiveId) ->
        index = @assignment.linked_objective_ids.indexOf(objectiveId)
        if index > -1 then @assignment.linked_objective_ids.splice(index, 1) else @assignment.linked_objective_ids.push(objectiveId)

      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)
  }
]
