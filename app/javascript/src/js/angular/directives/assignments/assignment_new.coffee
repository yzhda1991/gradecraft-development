# Entry point for a new assignment. Once the assignment is
# created, the edit form is disiplayed
gradecraft.directive 'assignmentNew', ['AssignmentTypeService', 'AssignmentService', 'LearningObjectivesService', '$q', (AssignmentTypeService, AssignmentService, LearningObjectivesService, $q) ->
  AssignmentNewCtrl = [() ->
    vmAssignmentNew = this
    vmAssignmentNew.loading = true

    vmAssignmentNew.useRubric = false
    vmAssignmentNew.assignmentCreated = false
    vmAssignmentNew.assignments = AssignmentService.assignments
    vmAssignmentNew.assignmentTypes = AssignmentTypeService.assignmentTypes
    vmAssignmentNew.termFor = AssignmentTypeService.termFor

    services(@courseUsesLearningObjectives).then(() ->
      vmAssignmentNew.loading = false
    )

    vmAssignmentNew.newAssignment = {
      assignment_type_id: null
      name: null
    }

    vmAssignmentNew.createAssignment = () ->
      AssignmentService.createAssignment(vmAssignmentNew.newAssignment, vmAssignmentNew.useRubric).then(() ->
        if AssignmentService.assignments.length
          vmAssignmentNew.assignmentCreated = true
      )
  ]

  services = (usesLearningObjectives) ->
    promises = [AssignmentTypeService.getAssignmentTypes()]
    promises.push(LearningObjectivesService.getArticles("objectives")) if usesLearningObjectives is true
    $q.all(promises)

  {
    bindToController: true
    controller: AssignmentNewCtrl
    controllerAs: 'vmAssignmentNew'
    templateUrl: 'assignments/assignment_new.html'
    scope:
      courseUsesLearningObjectives: '='
  }
]
