@gradecraft.directive 'gradeFilesUploader', ['$parse', 'RubricService', ($parse, RubricService) ->
  UploadGradeFilesCtrl = [()->
    vm = this
    vm.gradeFiles = RubricService.gradeFiles

    vm.deleteFile = (file)->
      console.log("deleting!");
      RubricService.deleteGradeFile(file)
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
@gradecraft.directive('gradeFilesUpload', ['$parse', 'RubricService', ($parse, RubricService)->
  return {
    restrict: 'A',
    link: (scope, element, attrs)->
      model = $parse(attrs.gradeFilesUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          RubricService.postGradeFiles(element[0].files)
        );
      );
    };
]);
