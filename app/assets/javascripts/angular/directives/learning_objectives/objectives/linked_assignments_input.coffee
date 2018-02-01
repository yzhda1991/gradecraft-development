@gradecraft.directive "learningObjectivesLinkedAssignmentsInput", ["LearningObjectivesService", "AssignmentService", "$timeout", (LearningObjectivesService, AssignmentService, $timeout) ->
  {
    scope:
      objective: "="
    controllerAs: "loAssignmentsInputCtrl"
    templateUrl: "learning_objectives/objectives/linked_assignments_input.html"
    link: (scope, elem, attr) ->
      scope.loading = true
      scope.assignments = []
      scope.selectedAssignments = []

      scope.persist = () ->
        scope.objective.learning_objective_links_attributes = scope.selectedAssignments
        LearningObjectivesService.persistArticle(scope.objective, "objectives")

      AssignmentService.getAssignments().then(() ->
        scope.loading = false
        scope.assignments = AssignmentService.assignments
        scope.selectedAssignments = _.pluck(LearningObjectivesService.linkedAssignments, "id")

        $timeout(() ->
          angular.element(elem[0].getElementsByClassName("select2")[0]).select2({
            placeholder: "Linked Assignments"
            allowClear: true
            multiple: true
          })
        )
      )
  }
]
