# Handles uploading assignment import files

@gradecraft.directive 'assignmentImportUploader', [() ->
  AssignmentImportUploaderCtrl = [() ->
    vm = this
    # vm.fileUploads = GradeService.fileUploads
  ]

  {
    bindToController: true,
    controller: AssignmentImportUploaderCtrl,
    controllerAs: 'vm',
    templateUrl: 'assignments/import/uploader.html'
  }
]

@gradecraft.directive('assignmentImportUpload', ['$parse', 'AssignmentImporterService',
  ($parse, AssignmentImporterService) ->
    {
      scope:
        provider: '@'
      restrict: 'A',
      link: (scope, element, attrs) ->
        element.bind('change', () ->
          scope.$apply(() ->
            formData = new FormData()
            formData.append('file', element[0].files[0])
            AssignmentImporterService.postUpload(scope.provider, formData)
          )
        )
    }
])
