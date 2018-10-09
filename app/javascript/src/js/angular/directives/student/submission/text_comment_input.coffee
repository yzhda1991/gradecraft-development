# Controls and renders the froala editor, which autosaves and loads Submission draft content
@gradecraft.directive 'textCommentInput', ['StudentSubmissionService', (StudentSubmissionService) ->

  TextCommentInputCtrl = ['$scope', ($scope) ->
    vm = this
    vm.loading = true
    vm.submission = StudentSubmissionService.submission

    vm.queueSaveDraftSubmission = () ->
      StudentSubmissionService.queueSaveDraftSubmission(vm.assignmentId)

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then(() ->
      vm.submission.text_comment_draft = vm.submission.text_comment if !vm.submission.text_comment_draft?
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
  }
]
