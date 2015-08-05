@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    getGradeSchemeElements = ()->
      $http.get('/gse_mass_edit/')

    postGradeSchemeElement = (id)->
      $http.put('/grade_scheme_elements/' + id).success(
        (data) ->
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    postGradeSchemeElements = (grade_scheme_elements)->
      $http.put('/grade_scheme_elements/mass_edit', grade_scheme_elements_attributes: grade_scheme_elements).success(
        (data) ->
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    gradeSchemeConfig = {
      className: 'row',
      fieldGroup: [
        {
          className: 'small-12 medium-2 columns',
          type: 'input',
          key: 'letter',
          templateOptions: {
            label: 'Letter',
            maxlength: 3,
            minlength: 2,
            placeholder: ''
          }
          # validators: {
            # ipAddress: {
              # expression: (viewValue, modelValue) ->
              #   value = modelValue || viewValue;
              #   '/(\d{1,3}\.){3}\d{1,3}/'.test(value)
              # message: '$viewValue + " is not a valid IP Address"'
            # }
          # },
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

    return {
        getGradeSchemeElements: getGradeSchemeElements
        postGradeSchemeElement: postGradeSchemeElement
        postGradeSchemeElements: postGradeSchemeElements
        gradeSchemeConfig: gradeSchemeConfig
    }
]
