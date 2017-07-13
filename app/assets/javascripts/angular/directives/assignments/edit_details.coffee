@gradecraft.directive 'assignmentEditDetails', ['AssignmentTypeService', 'AssignmentService', (AssignmentTypeService, AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }
    templateUrl: 'assignments/edit_details.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor


      scope.updateAssignment = ()->
        AssignmentService.queueUpdateAssignment(@assignment.id)
  }
]
