# adapted from https://uncorkedstudios.com/blog/multipartformdata-file-upload-with-angularjs
@gradecraft.directive('gradeFileUpload', ['$parse', 'RubricService', ($parse, RubricService)->
  return {
    restrict: 'A',
    link: (scope, element, attrs)->
      model = $parse(attrs.gradeFileUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          RubricService.postGradeFiles(element[0].files)
        );
      );
    };
]);
