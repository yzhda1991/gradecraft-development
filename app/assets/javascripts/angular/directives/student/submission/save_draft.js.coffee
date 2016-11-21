@gradecraft.directive 'saveDraft', ['StudentSubmissionService', (StudentSubmissionService) ->

  SaveDraftCtrl = [() ->
    vm = this

    vm.saveSubmission = () ->
      StudentSubmissionService.saveDraftSubmission(vm.assignmentId)
  ]

  {
    bindToController: true,
    controller: SaveDraftCtrl,
    controllerAs: 'vm',
    restrict: 'C',
    scope: {
      assignmentId: '@'
    }
    templateUrl: 'student/submission/save_draft.html'
  }
]
