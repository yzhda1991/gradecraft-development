# Main entry point for loading gradebook
@gradecraft.directive 'gradebook', [() ->
  GradebookCtrl = [() ->
    vm = this
    vm.loading = true

    vm.students = []

  ]

  {
    bindToController: true
    controller: GradebookCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'gradebook/main.html'
  }
]
