@gradecraft.directive 'studentSubmission', ['StudentSubmissionService', (StudentSubmissionService) ->

  StudentSubmissionCtrl = ['$scope', '$timeout', ($scope, $timeout) ->
    vm = this
    vm.loading = true
    vm.saveTimeout = null

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then(() ->
      vm.loading = false
    )

    $scope.submission = StudentSubmissionService.getSubmission()
    $scope.$watch('submission.text_comment_draft', (val) ->
      if val?
        $timeout.cancel(vm.saveTimeout) if vm.saveTimeout?

        vm.saveTimeout = $timeout(() ->
          StudentSubmissionService.saveDraftSubmission(vm.assignmentId)
        , 3500)
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
