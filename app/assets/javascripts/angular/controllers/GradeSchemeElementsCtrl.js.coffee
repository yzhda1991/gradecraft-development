@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    gse.model.grade_scheme_elements = response.grade_scheme_elements.slice().reverse()
    init()

  gse = @
  gse.onSubmit = () ->
    # debugger
    # console.log(gse.model)
    # GradeSchemeElementsService.postGradeSchemeElement(11)
    GradeSchemeElementsService.postGradeSchemeElements(gse.model.grade_scheme_elements)

  init = () ->
    gse.fields = [
      {
        type: 'gradeScheme',
        key: 'grade_scheme_elements',
        templateOptions: {
          btnText:'Add A Level',
          fields: [
            GradeSchemeElementsService.gradeSchemeConfig
          ]
        }
      }
    ]
    return

  gse.originalFields = angular.copy(gse.fields);

  return
]
