gradecraft.directive "assignmentShowGroupTableBody", ["AssignmentService", "AssignmentTypeService", "AssignmentGradesService", "SortableService", "$sce", "$q",
  (AssignmentService, AssignmentTypeService, AssignmentGradesService, SortableService, $sce, $q) ->
    AssignmentShowGroupTableBodyCtrl = [() ->
      vm = this
      vm.sortable = SortableService

      vm.loading = AssignmentGradesService.isLoading
      vm.groups = AssignmentGradesService.groups
      vm.groupGrades = AssignmentGradesService.groupGrades
      vm.assignment = AssignmentService.assignment

      vm.termFor = (term) -> AssignmentGradesService.termFor(term)
      vm.sanitizeHtml = (html) -> $sce.trustAsHtml(html)
      vm.gradesForGroup = (group) -> AssignmentGradesService.gradesForGroup(group)

      vm.showSubmitButton = (group) ->
        @linksVisible && vm.assignment().accepts_submissions && !group.has_group_submission

      vm.showEditGroupGradeLink = (group) ->
        grades = vm.gradesForGroup(group)
        first = grades[0]
        return false unless first? && @linksVisible
        first.instructor_modified is true

      services(@assignmentId).then(() ->
        AssignmentTypeService.getAssignmentType(vm.assignment().assignment_type_id)
      )
    ]

    services = (assignmentId) ->
      promises = [
        AssignmentService.getAssignment(assignmentId),
        AssignmentGradesService.getGroupGradesForAssignment(assignmentId)
      ]
      $q.all(promises)

    {
      scope:
        assignmentId: "@"
        linksVisible: "@"
      bindToController: true
      controller: AssignmentShowGroupTableBodyCtrl
      controllerAs: "groupTableBodyCtrl"
      templateUrl: "assignments/show/group/table_body.html"
    }
]
