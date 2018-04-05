@gradecraft.directive 'assignmentShowTableBody', ['AssignmentService', 'AssignmentTypeService', 'StudentService', 'SortableService', '$sce',
  (AssignmentService, AssignmentTypeService, StudentService, SortableService, $sce) ->
    AssignmentShowTableBodyCtrl = [() ->
      vm = this
      vm.loading = true
      vm.sortable = SortableService

      vm.assignment = AssignmentService.assignment
      vm.assignmentType = AssignmentTypeService.assignmentType
      vm.students = StudentService.students

      vm.tooltipDescribedBy = (type="feedback-read-tip")->
        "#{type}_#{vm.assignment().id}"

      vm.manuallyUnlockPath = (studentId) ->
        "/unlock_states/#{vm.assignment().id}/manually_unlock?student_id=#{studentId}&assignment_id=#{vm.assignment().id}"

      vm.termFor = (term) -> StudentService.termFor(term)
      vm.sanitize = (html) -> $sce.trustAsHtml(html)

      vm.showGradeButton = (student) ->
        (!vm.assignment().is_unlockable || student.assignment_unlocked) && vm.linksVisible

      vm.showUnlockButton = (student) ->
        vm.assignment().is_unlockable && !student.assignment_unlocked && vm.linksVisible

      vm.showGradeScore = (student) ->
        student.weighted_assignments && student.grade_instructor_modified

      vm.showFinalPoints = (student) ->
        !vm.assignment().pass_fail && student.grade_instructor_modified

      vm.showPassFailStatus = (student) ->
        vm.assignment().pass_fail && student.grade_instructor_modified &&
          student.grade_pass_fail_status?

      StudentService.getForAssignment(vm.assignment().id).then(() ->
        vm.loading = false
      )
    ]

    {
      scope:
        linksVisible: '@'
      bindToController: true
      controller: AssignmentShowTableBodyCtrl
      controllerAs: 'assignmentShowTableBodyCtrl'
      restrict: 'A'
      templateUrl: 'assignments/show/table_body.html'
    }
]
