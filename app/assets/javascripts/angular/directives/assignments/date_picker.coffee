# Creates a date time picker that manages due dates on an Assignment.

@gradecraft.directive 'assignmentDatePicker', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignmentId: "="
    }

    templateUrl: 'assignments/date_picker.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.AssignmentService = AssignmentService
      scope.assignments = AssignmentService.assignments

      scope.assignment = ()->
        _.find(AssignmentService.assignments, { id: scope.assignmentId })

      # For accessibility, each checkbox must have a label with a unique id
      scope.inputId = "assignment-#{scope.assignmentId}"

      scope.updateAssignmentDates = ()->
        AssignmentService.queueUpdateAssignment(id)
  }
]
