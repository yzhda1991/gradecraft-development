# switch for setting grade to release or save as draft

@gradecraft.directive 'gradeReleaseSwitch', ['GradeCraftAPI', 'GradeService', (GradeCraftAPI, GradeService) ->

  return {
    templateUrl: 'grades/release_switch.html'
    link: (scope, el, attr)->

      scope.switchState = ()->
        if GradeService.isSetToRelease() then "on" else "off"

      scope.textForSwitch = ()->
        if GradeService.isSetToRelease() then "Yes" else "No"

      scope.toggleSwitch = ()->
        GradeService.toggeleGradeReleaseStatus()
  }
]
