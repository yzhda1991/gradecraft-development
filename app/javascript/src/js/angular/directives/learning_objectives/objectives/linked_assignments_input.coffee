gradecraft.directive "learningObjectivesLinkedAssignmentsInput", ["LearningObjectivesService", "AssignmentService", "$timeout", (LearningObjectivesService, AssignmentService, $timeout) ->
  {
    scope:
      objective: "="
    controllerAs: "loAssignmentsInputCtrl"
    templateUrl: "learning_objectives/objectives/linked_assignments_input.html"
    link: (scope, elem, attr) ->
      scope.selectedAssignments = []
      scope.assignments = AssignmentService.assignments

      scope.termFor = (term) ->
        AssignmentService.termFor(term)

      scope.persist = () ->
        scope.objective.learning_objective_links_attributes = scope.selectedAssignments
        LearningObjectivesService.persistArticle(scope.objective, "objectives")

      do () ->
        assignments = _.filter(LearningObjectivesService.linkedAssignments, { objective_id: scope.objective.id })
        angular.copy(_.pluck(assignments, "assignment_id"), scope.selectedAssignments)

      $timeout(() ->
        angular.element(elem[0].getElementsByClassName("select2")[0]).select2({
          placeholder: "Linked #{scope.termFor("assignments")}"
          allowClear: true
          multiple: true
        })
      )
  }
]
