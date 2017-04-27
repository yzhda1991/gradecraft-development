# Creates a date time picker that manages due dates on an Assignment.

@gradecraft.directive 'assignmentFullPoints', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }

    templateUrl: 'assignments/full_points.html',
    link: (scope, el, attr, ngModelCtrl)->
      scope.termFor = AssignmentService.termFor

      scope.updateAssignmentPoints = ()->
        AssignmentService.queueUpdateAssignment(scope.assignment.id)
  }
]
