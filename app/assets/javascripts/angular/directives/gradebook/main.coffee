# Main entry point for loading gradebook
@gradecraft.directive 'gradebook', ['GradebookService', '$q', (GradebookService, $q) ->
  GradebookCtrl = [() ->
    vm = this
    vm.loading = true

    vm.students = GradebookService.students
    vm.assignments = GradebookService.assignments

    _initialize().then(() ->
      vm.loading = false
    )

  ]

  _initialize = () ->
    promises = [
      GradebookService.getAssignments(),
      GradebookService.getStudents()
    ]
    $q.all(promises)

  {
    scope:
      termForBadge: '@'
      termForStudent: '@'
      hasBadges: '@'
    bindToController: true
    controller: GradebookCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'gradebook/main.html'
  }
]
