@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    #$scope.generateInputs(response.grade_scheme_elements)
    #debugger

  $scope.gse = @
  $scope.gse.model = {}
  $scope.gse.fields = []

  $scope.generateInput = (element) ->
    tmp = {}
    tmp.type = 'input'
    tmp.templateOptions = {}
    tmp.key = 'parentType'
    tmp.templateOptions.label = element.letter
    tmp

  $scope.gse.fields = [
    {
     key: 'email',
     type: 'input',
     templateOptions: {
       type: 'email',
       label: 'Email address',
       placeholder: 'Enter email'
     }
    },
    {
     key: 'password',
     type: 'input',
     templateOptions: {
       type: 'password',
       label: 'Password',
       placeholder: 'Password'
     }
    },
    {
     key: 'file',
     type: 'file',
     templateOptions: {
       label: 'File input',
       description: 'Example block-level help text here',
       url: 'https://example.com/upload'
     }
    },
    {
     key: 'checked',
     type: 'checkbox',
     templateOptions: {
       label: 'Check me out'
     }
    }
  ];

  $scope.generateInputs = (elements) ->
    fields = []
    angular.forEach elements, (element, index)->
      fields.push $scope.generateInput(element)
    $scope.gse.fields = fields
  return
]

