@gradecraft.directive 'fileAttachmentsUploader', ['$parse', 'GradeService', ($parse, GradeService) ->
  UploadCtrl = [()->
    vm = this
    vm.fileAttachments = GradeService.fileAttachments

    vm.deleteFile = (file)->
      GradeService.deleteGradeFile(file)
  ]

  {
    bindToController: true,
    controller: UploadCtrl,
    controllerAs: 'vm',
    scope: {},
    templateUrl: 'grades/upload_file_attachments.html'
  }
]

# adapted from https://uncorkedstudios.com/blog/multipartformdata-file-upload-with-angularjs
@gradecraft.directive('fileAttachmentsUpload', ['$parse', 'GradeService', ($parse, GradeService)->
  return {
    restrict: 'A',
    link: (scope, element, attrs)->
      model = $parse(attrs.fileAttachmentsUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          GradeService.postGradeFiles(element[0].files)
        );
      );
    };
]);
