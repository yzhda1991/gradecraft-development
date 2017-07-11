@gradecraft.directive 'assignmentFormBasics', ['AssignmentTypeService', 'AssignmentService', (AssignmentTypeService, AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/form_basics.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor

      scope.assignmentTypes = AssignmentTypeService.assignmentTypes

      scope.updateAssignment = ()->
        AssignmentTypeService.assignmentTypes
        AssignmentService.queueUpdateAssignment(@assignment.id)
  }
]
