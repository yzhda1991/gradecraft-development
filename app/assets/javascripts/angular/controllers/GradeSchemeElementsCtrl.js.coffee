@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    generateFormModels(response.grade_scheme_elements)

  generateFormModels = (grade_scheme_elements) ->
    gse.model.grade_scheme_elements = grade_scheme_elements
    init()

    # gse.model = {
    #   gradeSchemes: [
    #     {
    #       letter:'abc',
    #       level:'',
    #       lowRange:'',
    #       highRange:''
    #     },
    #     {
    #       letter:'abc',
    #       level:'',
    #       lowRange:'',
    #       highRange:''
    #     }
    #   ]
    # }

    # 0: Object
    # course_id: 1
    # created_at: "2015-06-08T16:29:05.500-04:00"
    # description: null
    # grade_scheme_id: null
    # high_range: 600000
    # id: 1
    # letter: "F"
    # level: "Rat"
    # low_range: 0
    # updated_at: "2015-06-08T16:29:05.500-

  gse = @
  gse.onSubmit = () ->
    alert(JSON.stringify(gse.model), null, 2)

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
        key: 'gradeSchemes',
        templateOptions: {
          btnText:'Add another investment',
          fields: [
            fieldOne
          ]
        }
      }
    ]
    return
  gse.originalFields = angular.copy(gse.fields);

  return
]
