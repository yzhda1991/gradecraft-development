# Handles uploading assignment import files
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
