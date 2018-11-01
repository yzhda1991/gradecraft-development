# switch for setting grade to Complete or save as draft

gradecraft.directive 'gradeCompleteSwitch', ['GradeCraftAPI', 'GradeService', (GradeCraftAPI, GradeService) ->

  return {
    templateUrl: 'grades/complete_switch.html'
    link: (scope, el, attr)->

      scope.switchState = ()->
        if GradeService.isSetToComplete() then "on" else "off"

      scope.textForSwitch = ()->
        if GradeService.isSetToComplete() then "Yes" else "No"

      scope.toggleComplete = ()->
        GradeService.toggleComplete()
  }
]
