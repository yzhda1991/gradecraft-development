@gradecraft.directive 'textCommentInput', ['StudentSubmissionService', (StudentSubmissionService) ->

  TextCommentInputCtrl = ['$scope', ($scope) ->
    vm = this
    vm.loading = true
    vm.queueDraftSubmissionSave = () ->
      StudentSubmissionService.queueDraftSubmissionSave(vm.assignmentId)

    $scope.submission = StudentSubmissionService.getSubmission()

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then(() ->
      vm.loading = false
    )
  ]

  {
    bindToController: true
    controller: TextCommentInputCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    scope: {
      assignmentId: '@'
    }
    templateUrl: 'student/submission/text_comment_input.html'
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
