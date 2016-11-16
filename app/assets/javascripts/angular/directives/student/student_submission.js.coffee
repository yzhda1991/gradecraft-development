@gradecraft.directive 'studentSubmission', ['StudentSubmissionService', (StudentSubmissionService) ->

  StudentSubmissionCtrl = [() ->
    vm = this
    vm.loading = true
    vm.saveSubmission = () ->
      StudentSubmissionService.saveDraftSubmission(vm.assignmentId, vm.submission).then((result) ->
        vm.submission = result if result?
      )

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then((submission) ->
      vm.submission = submission
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
    },
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
