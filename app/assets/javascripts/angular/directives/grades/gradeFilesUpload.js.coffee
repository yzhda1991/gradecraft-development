@gradecraft.directive 'fileUploadsUploader', ['$parse', 'GradeService', ($parse, GradeService) ->
  UploadCtrl = [()->
    vm = this
    vm.fileUploads = GradeService.fileUploads

    vm.deleteFile = (file)->
      GradeService.deleteAttachment(file)
  ]

  {
    bindToController: true,
    controller: UploadCtrl,
    controllerAs: 'vm',
    scope: {},
    templateUrl: 'grades/upload_file_uploads.html'
  }
]

# adapted from https://uncorkedstudios.com/blog/multipartformdata-file-upload-with-angularjs
@gradecraft.directive('fileUploadsUpload', ['$parse', 'GradeService', ($parse, GradeService)->
  return {
    restrict: 'A',
    link: (scope, element, attrs)->
      model = $parse(attrs.fileUploadsUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          GradeService.postAttachments(element[0].files)
        );
      );
    };
]);
