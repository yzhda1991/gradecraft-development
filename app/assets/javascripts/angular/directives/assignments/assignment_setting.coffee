# Creates a checkbox that manages a boolean state on an Assignment. Note that
# the state of the attribute is passed directly to the scope, rather than querried
# and stored on the Assignment in the service.  This simplifies state management.
# and allows the service to continue to operate in the Predictor with boolean
# states that don't map to the model.
#
# For example:
#   in ruby: assignment.accepts_submissions
#   in the service: assignment.is_accepting_submissions
# The booleans passed in the json takes into account the due dates and closing
# dates, and calculate state management before being picked up by Angular.
#
# We could update this if we find a need to have the assigments in the service
# remain in sync with updates performed on tehe settings page.
# We would have to map all boolean attributes back to those on the server.

@gradecraft.directive 'assignmentSetting', ['AssignmentService', (AssignmentService) ->

  return {
    scope: {
      assignmentId: "="
      attribute: "@"
      checked: "="
    }
    templateUrl: 'assignments/assignment_settings.html',
    link: (scope, el, attr)->
      # For accessibility, each checkbox must have a label with a unique id
      scope.inputId = "checkbox-assignment-#{scope.assignmentId}-#{scope.attribute}"

      scope.assignment = ()->
        _.find(AssignmentService.assignments, {id: scope.assignmentId})

      scope.updateAttribute = ()->
        scope.checked = !scope.checked
        AssignmentService.updateAssignmentAttribute(
          scope.assignmentId, scope.attribute,scope.checked
        )
  }
]
