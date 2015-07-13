@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (gse)->
    $scope.gradeSchemeElements = gse
    # debugger
  gse = @
  gse.model = {}
  gse.fields = [
    {
      type: 'input',
      templateOptions: {
        label: 'foo1'
      }
    }
  ]
]
