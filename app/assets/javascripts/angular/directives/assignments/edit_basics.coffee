@gradecraft.directive 'assignmentEditBasics', ['AssignmentTypeService', 'AssignmentService', (AssignmentTypeService, AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/edit_basics.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor

      scope.assignmentTypes = AssignmentTypeService.assignmentTypes

      scope.updateAssignment = ()->
        AssignmentTypeService.assignmentTypes
        AssignmentService.queueUpdateAssignment(@assignment.id)
  }
]
