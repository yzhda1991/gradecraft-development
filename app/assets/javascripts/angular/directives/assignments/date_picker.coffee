# Creates a date time picker that manages due dates on an Assignment.

@gradecraft.directive 'assignmentDatePicker', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignment: "="
    }

    templateUrl: 'assignments/date_picker.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.updateAssignmentDates = ()->
        AssignmentService.queueUpdateAssignment(scope.assignment.id)
  }
]
