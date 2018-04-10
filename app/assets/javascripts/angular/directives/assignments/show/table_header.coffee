@gradecraft.directive "assignmentShowTableHeader", ["AssignmentService", "AssignmentTypeService", "GradeReleaseService", "StudentService",
  (AssignmentService, AssignmentTypeService, GradeReleaseService, StudentService) ->
    AssignmentShowTableHeaderCtrl = [() ->
      vm = this
      vm.loading = true
      vm.assignment = AssignmentService.assignment
      vm.assignmentType = AssignmentTypeService.assignmentType

      vm.termFor = (term) -> AssignmentService.termFor(term)
      vm.hasStudents = () -> _.any(StudentService.students)

      vm.showScore = () ->
        !vm.assignmentType.student_weightable && !vm.assignment().pass_fail

      vm.showWeightedScore = () ->
        vm.assignmentType.student_weightable && vm.assignment().pass_fail

      vm.showGrade = () ->
        !vm.assignmentType.student_weightable && vm.assignment().pass_fail

      vm.selectGrades = (select) ->
        gradeIds = _pluckNonNullGradeIds(StudentService.students)
        GradeReleaseService.clearGradeIds()
        GradeReleaseService.addGradeIds(gradeIds...) if select is true
    ]

    _pluckNonNullGradeIds = (students) ->
      gradeIds = []
      (gradeIds.push(student.grade_id) if student.grade_id? and student.grade_not_released is true) for student in students
      gradeIds

    {
      bindToController: true
      controller: AssignmentShowTableHeaderCtrl
      controllerAs: "assignmentShowTableHeaderCtrl"
      restrict: "A"
      templateUrl: "assignments/show/table_header.html"
    }
]
