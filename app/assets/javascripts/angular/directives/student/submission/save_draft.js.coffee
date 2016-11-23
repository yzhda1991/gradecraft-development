@gradecraft.directive 'saveDraft', ['StudentSubmissionService', (StudentSubmissionService) ->

  SaveDraftCtrl = [() ->
    vm = this

    vm.queueDraftSubmissionSave = () ->
      StudentSubmissionService.queueDraftSubmissionSave(vm.assignmentId, true)
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
