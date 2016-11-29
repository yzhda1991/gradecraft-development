@gradecraft.directive 'gradeFilesUploader', ['$parse', 'GradeService', ($parse, GradeService) ->
  UploadGradeFilesCtrl = [()->
    vm = this
    vm.gradeFiles = GradeService.gradeFiles

    vm.deleteFile = (file)->
      GradeService.deleteGradeFile(file)
  ]

  {
    bindToController: true,
    controller: UploadGradeFilesCtrl,
    controllerAs: 'vm',
    scope: {},
    templateUrl: 'grades/upload_grade_files.html'
  }
]

# adapted from https://uncorkedstudios.com/blog/multipartformdata-file-upload-with-angularjs
@gradecraft.directive('gradeFilesUpload', ['$parse', 'GradeService', ($parse, GradeService)->
  return {
    restrict: 'A',
    link: (scope, element, attrs)->
      model = $parse(attrs.gradeFilesUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          GradeService.postGradeFiles(element[0].files)
        );
      );
    };
]);
