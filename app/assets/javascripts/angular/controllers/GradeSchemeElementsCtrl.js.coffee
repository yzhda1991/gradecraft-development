@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    #$scope.generateInputs(response.grade_scheme_elements)

  gse = @
  gse.onSubmit = () ->
    alert(JSON.stringify(gse.model), null, 2)
  #$scope.gse.model = {}
  # $scope.gse.fields = []

  gse.author = {
    # name: 'Joe Zhou',
    # url: 'https://plus.google.com/u/0/111062476999618400219/posts'
  }
  gse.exampleTitle = 'Repeating Section';
  # gse.env = {
  #   angularVersion: angular.version.full,
  #   formlyVersion: formlyVersion
  # }

  fieldOne = {
    className: 'row',
    fieldGroup: [
      {
        className: 'small-12 medium-2 columns',
        type: 'input',
        key: 'letter',
        templateOptions: {
          label: 'Letter'
        }
      },
      {
        className: 'small-12 medium-2 columns',
        type: 'input',
        key: 'level',
        templateOptions: {
          label: 'Level'
        }
      },
      {
        className: 'small-12 medium-2 columns',
        type: 'input',
        key: 'lowRange',
        templateOptions: {
          label: 'Low Range',
          required: true
        }
      },
      {
        className: 'small-12 medium-2 columns',
        type: 'input',
        key: 'highRange',
        templateOptions: {
          label: 'High Range',
          required: true
        }
      }
    ]
  }

  init = () ->
    gse.fields = [
      {
        type: 'gradeScheme',
        key: 'investments',
        templateOptions: {
          btnText:'Add another investment',
          fields: [
            fieldOne
          ]
        }
      }
    ]
    gse.model = {
      investments: [
        {
          investmentName:'abc',
          investmentDate:(new Date()).toDateString(),
          stockIdentifier:'',
          investmentValue:'',
          relationshipName:'',
          complianceApprover:'',
          requestorComment:''
        },
        {
          investmentName:'haf',
          investmentDate:(new Date()).toDateString(),
          stockIdentifier:'',
          investmentValue:'',
          relationshipName:'',
          complianceApprover:'',
          requestorComment:''
        }
      ]
    }
    return

  init()
  gse.originalFields = angular.copy(gse.fields);

  # $scope.generateInput = (element) ->
  #   tmp = {}
  #   tmp.type = 'input'
  #   tmp.templateOptions = {}
  #   tmp.key = 'parentType'
  #   tmp.templateOptions.label = element.letter
  #   tmp

  # $scope.generateInputs = (elements) ->
  #   fields = []
  #   angular.forEach elements, (element, index)->
  #     fields.push $scope.generateInput(element)
  #   $scope.gse.fields = fields
  return
]
