@gradecraft.directive 'gradePassFail', ['GradeCraftAPI', 'AssignmentService', 'GradeService', (GradeCraftAPI, AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/pass_fail.html'
    link: (scope, el, attr)->

      scope.switchState = ()->
        if GradeService.grade.pass_fail_status == "Pass" then "on" else "off"

      scope.textForSwitch = ()->
        if GradeService.grade.pass_fail_status == "Pass" then GradeCraftAPI.termFor("pass") else GradeCraftAPI.termFor("fail")

      scope.toggleSwitch = ()->
        GradeService.grade.pass_fail_status = if GradeService.grade.pass_fail_status == "Pass" then "Fail" else "Pass"
        GradeService.queueUpdateGrade()
  }
]
