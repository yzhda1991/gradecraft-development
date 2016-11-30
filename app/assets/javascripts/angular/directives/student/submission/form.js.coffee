@gradecraft.directive 'studentSubmissionForm', ['StudentSubmissionService', (StudentSubmissionService) ->

  StudentSubmissionFormCtrl = [() ->
    vm = this
    vm.submission = StudentSubmissionService.getSubmission()
  ]

  {
    restrict: 'C', # restrict to class
    bindToController: true,
    controller: StudentSubmissionFormCtrl,
    controllerAs: 'vm',
    scope: {
      assignmentId: '@'
    },
    link: (scope, el, attr, controller) ->
      scope.$watch(() ->
        controller.submission
      , (newValue, oldValue) ->
        if newValue?
          attr.$set('action', if newValue.id? then "/assignments/#{controller.assignmentId}/submissions/#{newValue.id}" else "/assignments/#{controller.assignmentId}/submissions")
      , true)
  }
]
