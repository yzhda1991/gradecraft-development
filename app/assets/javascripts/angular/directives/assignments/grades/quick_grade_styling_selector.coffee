# Selector for updating quick grade styling on a mass edit form
@gradecraft.directive 'quickGradeStylingSelector', ['AssignmentGradesService', (AssignmentGradesService) ->
  radioButtonOption = { value: 'radio', label: 'Radio Button (Quick Grade Style)' }
  selectOption = { value: 'select', label: 'Select Menu (Quick Grade Style)' }
  textOption = { value: 'text', label: 'Text Box (Quick Grade Style)' }

  {
    templateUrl: 'assignments/grades/quick_grade_styling_selector.html'
    link: (scope, element, attr) ->
      scope.options = () ->
        assignment = AssignmentGradesService.assignment
        if assignment.pass_fail
          [radioButtonOption]
        else if assignment.has_levels
          [radioButtonOption, selectOption]
        else
          [radioButtonOption, textOption]

      scope.selectedGradingStyle = AssignmentGradesService.selectedGradingStyle

      scope.disabled = () ->
        assignment = AssignmentGradesService.assignment
        _.isEmpty(assignment) or assignment.pass_fail is true
  }
]
