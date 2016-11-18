@gradecraft.directive 'studentSubmission', ['StudentSubmissionService', (StudentSubmissionService) ->

  StudentSubmissionCtrl = ['$scope', ($scope) ->
    vm = this
    vm.loading = true
    $scope.submission = StudentSubmissionService.submission

    vm.saveSubmission = () ->
      StudentSubmissionService.saveDraftSubmission(vm.assignmentId)

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then(() ->
      $scope.submission = StudentSubmissionService.getSubmission()
      vm.loading = false
    )
  ]

  {
    bindToController: true,
    controller: StudentSubmissionCtrl,
    controllerAs: 'vm',
    restrict: 'EA',
    scope: {
      assignmentId: '@'
    }
    templateUrl: 'student/submission/main.html'
    link: (scope, el, attr) ->
      scope.froalaOptions = {
        inlineMode: false,
        heightMin: 200,
        toolbarButtons: [
          'fullscreen', 'bold', 'italic', 'underline', 'strikeThrough',
          'sep', 'blockStyle', 'emoticons', 'insertTable', 'formatOL', 'formatUL','align',
          'outdent', 'indent', 'insertLink', 'undo', 'redo',
          'clearFormatting', 'selectAll', 'html'
        ]
      }
  }
]
