@gradecraft.directive 'studentSubmission', ['StudentSubmissionService', (StudentSubmissionService) ->

  StudentSubmissionCtrl = ['$scope', ($scope) ->
    vm = this
    vm.loading = true
    vm.timer =

    $scope.submission = StudentSubmissionService.getSubmission()

    # Need alternative to using debounce on ng-model-options because delaying
    # model updates causes problems on dependent consumers of that value
    vm.saveSubmission = () ->
      StudentSubmissionService.saveDraftSubmission(vm.assignmentId)

    StudentSubmissionService.getDraftSubmission(vm.assignmentId).then(() ->
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
