# switch for setting grade to student_visible

@gradecraft.directive 'gradeVisibleSwitch', ['GradeCraftAPI', 'GradeService', (GradeCraftAPI, GradeService) ->

  return {
    templateUrl: 'grades/visible_switch.html'
    link: (scope, el, attr)->

      scope.isDisabled = ()->
        !GradeService.isSetToComplete()

      scope.visibleSwitchState = ()->
        return "off" if scope.isDisabled()
        if GradeService.isSetToStudentVisible() then "on" else "off"

      scope.textForVisibleSwitch = ()->
        return "No" if scope.isDisabled()
        if GradeService.isSetToStudentVisible() then "Yes" else "No"

      scope.toggleStudentVisible = ()->
        return if scope.isDisabled()
        GradeService.toggleStudentVisible()
  }
]
