# Entry point for editing an assignment
@gradecraft.directive 'assignmentEdit', ['$q', 'AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', ($q, AssignmentTypeService, AssignmentService, LearningObjectivesService) ->
  AssignmentEditCtrl = [() ->
    vmAssignmentEdit = this
    vmAssignmentEdit.loading = true

    vmAssignmentEdit.assignments = AssignmentService.assignments

    services(@assignmentId, @courseUsesLearningObjectives).then(() ->
      vmAssignmentEdit.loading = false
    )
  ]

  services = (id, usesLearningObjectives) ->
    promises = [
      AssignmentService.getAssignment(id),
      AssignmentTypeService.getAssignmentTypes()
    ]
    promises.push(LearningObjectivesService.getArticles("objectives")) if usesLearningObjectives is true
    $q.all(promises)

  {
    bindToController: true
    controller: AssignmentEditCtrl
    controllerAs: 'vmAssignmentEdit'
    templateUrl: 'assignments/assignment_edit.html'
    scope:
      courseUsesLearningObjectives: '='
      assignmentId: "="
      rubricId: '='
  }
]
