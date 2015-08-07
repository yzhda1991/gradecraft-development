@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  gse = @
  gse.model = {}

  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    gse.model.grade_scheme_elements = response.grade_scheme_elements.slice().reverse()
    init()

  gse.onSubmit = () ->
    GradeSchemeElementsService.postGradeSchemeElements(gse.model.grade_scheme_elements)

  gse.submitRow = (id) ->
    GradeSchemeElementsService.postGradeSchemeElement(id)

  init = () ->
    gse.fields = [
      {
        type: 'gradeScheme',
        key: 'grade_scheme_elements',
        templateOptions: {
          btnText:'Add A Level',
          fields: [
            {
              className: 'row',
              fieldGroup: [
                {
                  className: 'small-12 medium-2 columns',
                  type: 'input',
                  key: 'letter',
                  templateOptions: {
                    label: 'Letter',
                    placeholder: ''
                  }
                  validators: {
                    input: {
                      expression: (viewValue, modelValue) ->
                        value = modelValue || viewValue;
                        temp = /^([ABCDEF][+-]?)$/.test(value)
                      message: '$viewValue + " is not a letter grade"'
                    }
                  },
                  # modelOptions: {
                  #   debounce: {
                  #     blur: 0
                  #   },
                  #   updateOn: "blur"
                  # }
                },
                {
                  className: 'small-12 medium-2 columns',
                  type: 'input',
                  key: 'level',
                  templateOptions: {
                    label: 'Level'
                  }
                  # modelOptions: {
                  #   debounce: {
                  #     blur: 0
                  #   },
                  #   updateOn: "blur"
                  # }
                },
                {
                  className: 'small-12 medium-2 columns',
                  type: 'input',
                  key: 'low_range',
                  templateOptions: {
                    label: 'Low Range',
                    required: true
                  },
                  # modelOptions: {
                  #   debounce: {
                  #     blur: 0
                  #   },
                  #   updateOn: "blur"
                  # },
                  validation: {
                    messages: {
                      required: (viewValue, modelValue, scope) ->
                        scope.to.label + ' is required'
                    }
                  },
                  validators: {
                    input: {
                      expression: (viewValue, modelValue) ->
                        temp = []
                        for element, i in gse.model.grade_scheme_elements
                          if(i > 0 && modelValue == element.low_range)
                            if(gse.model.grade_scheme_elements[i-1].low_range >= element.high_range)
                              break
                              return false
                      message: 'invalid'
                    }
                  }
                },
                {
                  className: 'small-12 medium-2 columns',
                  type: 'input',
                  key: 'high_range',
                  templateOptions: {
                    label: 'High Range',
                    required: true
                  },
                  # modelOptions: {
                  #   debounce: {
                  #     blur: 0
                  #   },
                  #   updateOn: "blur"
                  # },
                  validation: {
                    messages: {
                      required: (viewValue, modelValue, scope) ->
                        scope.to.label + ' is required'
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    ]
    return

  gse.originalFields = angular.copy(gse.fields);

  return
]
