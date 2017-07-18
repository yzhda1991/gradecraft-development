# Entry point for a new assignment. Once the assignment is
# created, the edit form is disiplayed
@gradecraft.directive 'assignmentNew', ['$q', 'AssignmentTypeService', 'AssignmentService', ($q, AssignmentTypeService, AssignmentService) ->
  AssignmentNewCtrl = [()->
    vmAssignmentNew = this
    vmAssignmentNew.loading = true
    vmAssignmentNew.assignmentCreated = false
    vmAssignmentNew.assignments = AssignmentService.assignments
    vmAssignmentNew.assignmentTypes = AssignmentTypeService.assignmentTypes
    vmAssignmentNew.termFor = AssignmentTypeService.termFor

    AssignmentTypeService.getAssignmentTypes().then(()->
      vmAssignmentNew.loading = false
    )

    vmAssignmentNew.newAssignment = {
      assignment_type_id: null,
      name: null
    }

    vmAssignmentNew.createAssignment = ()->
      AssignmentService.createAssignment(vmAssignmentNew.newAssignment).then(()->
        if AssignmentService.assignments.length
          vmAssignmentNew.assignmentCreated = true
      )
  ]


  {
    bindToController: true,
    controller: AssignmentNewCtrl,
    controllerAs: 'vmAssignmentNew',
    templateUrl: 'assignments/assignment_new.html',

  }
]
