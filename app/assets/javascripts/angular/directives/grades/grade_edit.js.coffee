@gradecraft.directive 'gradeEdit', ['$q', 'AssignmentService', 'GradeService',
  ($q, AssignmentService, GradeService) ->
    GradeCtrl = [()->
      vm = this

      vm.loading = true
      vm.gradeService = GradeService
      vm.AssignmentService = AssignmentService

      services(vm.assignmentId, vm.recipientType, vm.recipientId).then(()->
        vm.loading = false
      )
    ]

    services = (assignmentId, recipientType, recipientId)->
      promises = [
        AssignmentService.getAssignment(assignmentId)
        GradeService.getGrade(assignmentId, recipientType, recipientId)
      ]
      return $q.all(promises)

    {
      bindToController: true,
      controller: GradeCtrl,
      controllerAs: 'vm',
      restrict: 'EA',
      scope: {
         assignmentId: "=",
         recipientType: "@",
         recipientId: "="
        },
      templateUrl: 'grades/main.html'
    }
]






