# Main entry point for grading (standard/rubric individual/group)
# Renders appropriate grading form for grade and assignment type

@gradecraft.directive 'gradeEdit', ['$q', 'AssignmentService', 'GradeService',
  ($q, AssignmentService, GradeService) ->
    EditGradeCtrl = [()->
      vm = this

      vm.loading = true
      vm.gradeService = GradeService
      vm.AssignmentService = AssignmentService

      services(vm.assignmentId, vm.recipientType, vm.recipientId).then(()->
        vm.loading = false

        # set a default state for new pass/fail grades
        if AssignmentService.assignment().pass_fail && !GradeService.grade.pass_fail_status
          GradeService.grade.pass_fail_status = "Pass"
      )

      vm.gradeType = ()->
        assignment = AssignmentService.assignment()
        return "" if !assignment

        if assignment.pass_fail == true
          return "PASS_FAIL"
        if assignment.score_levels
          "SCORE_LEVELS"
        else
          "DEFAULT"
    ]

    services = (assignmentId, recipientType, recipientId)->
      promises = [
        AssignmentService.getAssignment(assignmentId)
        GradeService.getGrade(assignmentId, recipientType, recipientId)
      ]
      return $q.all(promises)

    {
      bindToController: true,
      controller: EditGradeCtrl,
      controllerAs: 'vm',
      scope: {
         assignmentId: "=",
         recipientType: "@",
         recipientId: "="
        },
      templateUrl: 'grades/edit.html'
    }
]


