# switch for pass/fail grades, alternative to raw_points

@gradecraft.directive 'gradePassFailSwitch', ['GradeCraftAPI', 'GradeService', (GradeCraftAPI, GradeService) ->

  return {
    templateUrl: 'grades/pass_fail_switch.html'
    link: (scope, el, attr)->

      scope.switchState = ()->
        if GradeService.gradeIsPassing() then "on" else "off"

      scope.textForTitle = ()->
        GradeCraftAPI.termFor("pass") + " / " + GradeCraftAPI.termFor("fail") + " Status"

      scope.textForSwitch = ()->
        if GradeService.gradeIsPassing() then GradeCraftAPI.termFor("pass") else GradeCraftAPI.termFor("fail")

      scope.toggleSwitch = ()->
        GradeService.toggleGradePassFailStatus()
        GradeService.queueUpdateGrade()
  }
]
