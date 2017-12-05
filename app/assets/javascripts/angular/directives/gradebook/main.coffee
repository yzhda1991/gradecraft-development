# Main entry point for loading gradebook
@gradecraft.directive 'gradebook', ['GradebookService', '$q', (GradebookService, $q) ->
  GradebookCtrl = ['$scope', ($scope) ->
    vm = this
    vm.loading = true

    vm.students = GradebookService.students
    vm.assignments = GradebookService.assignments

    vm.termFor = (article) ->
      GradebookService.termFor(article)

    _initialize().then(() ->
      vm.loading = false
    )

    vm.editGrade = (grade_link) ->
      if confirm 'This grade is about to be marked as ungraded and unavailable to the student - it won\'t be visible again until you click "Submit" - are you sure?'
        window.location = grade_link

    # For sortable headers
    $scope.propertyName = 'first_name'
    $scope.reverse = false

    $scope.sortBy = (propertyName, index=null) ->
      newPropertyName = if index? then "#{propertyName}[#{index}].value" else propertyName
      $scope.reverse = if $scope.propertyName == newPropertyName then !$scope.reverse else false
      $scope.propertyName = newPropertyName
  ]

  _initialize = () ->
    promises = [
      GradebookService.getAssignments(),
      GradebookService.getStudents()
    ]
    $q.all(promises)

  {
    scope:
      hasBadges: '@'
    bindToController: true
    controller: GradebookCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'gradebook/main.html'
  }
]
