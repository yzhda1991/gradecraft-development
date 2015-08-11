@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService',
  ($scope, $http, GradeSchemeElementsService) ->
    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      console.log($scope.grade_scheme_elements)
    )

    $scope.gradeService = GradeSchemeElementsService
    $scope.grade_scheme_elements = $scope.gradeService.elements
    return
]
# @gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
#   gse = @
#   gse.model = {}

#   GradeSchemeElementsService.getGradeSchemeElements().success (response)->
#     gse.model.grade_scheme_elements = response.grade_scheme_elements.slice().reverse()
#     console.log(response)
#     init()

#   gse.onSubmit = () ->
#     GradeSchemeElementsService.postGradeSchemeElements(gse.model.grade_scheme_elements)

#   gse.submitRow = (id) ->
#     GradeSchemeElementsService.postGradeSchemeElement(id)

#   gse.fields = [
#     {
#       className: 'row',
#       fieldGroup: [
#         {
#           className: 'small-12 medium-2 columns',
#           type: 'input',
#           key: 'letter',
#           templateOptions: {
#             label: 'Letter',
#             placeholder: ''
#           }
#           validators: {
#             input: {
#               expression: (viewValue, modelValue) ->
#                 value = modelValue || viewValue;
#                 temp = /^([ABCDEFGHIJKLMNOPQRSTUVWXYZ][+-]?)$/.test(value)
#               message: '$viewValue + " is not a letter grade"'
#             }
#           },
#         },
#         {
#           className: 'small-12 medium-2 columns',
#           type: 'input',
#           key: 'level',
#           templateOptions: {
#             label: 'Level'
#           }
#         },
#         {
#           className: 'small-12 medium-2 columns',
#           type: 'input',
#           key: 'low_range',
#           templateOptions: {
#             label: 'Low Range',
#             required: true
#           },
#           validation: {
#             messages: {
#               required: (viewValue, modelValue, scope) ->
#                 scope.to.label + ' is required'
#             }
#           },
#           expressionProperties: {
#             # 'gse.model.grade_scheme_elements[]': '$viewValue'
#           },
#           validators: {
#             input: {
#               expression: (viewValue, modelValue, scope) ->
#                 temp = []

#                 # for element, i in gse.model.grade_scheme_elements
#                 #   if(i > 0 && modelValue == element.low_range)
#                 #     if(gse.model.grade_scheme_elements[i-1].low_range >= element.high_range)
#                 #       break
#                 #       return false
#               message: 'invalid'
#             }
#           }
#         },
#         {
#           className: 'small-12 medium-2 columns',
#           type: 'input',
#           model: 'gse.model.grade_scheme_elements[1].low_range',
#           templateOptions: {
#             label: 'High Range',
#             disabled: true
#           },
#           controller: ($scope) ->
#             debugger
#           # modelOptions: {
#           #   debounce: {
#           #     blur: 0
#           #   },
#           #   updateOn: "blur"
#           # }
#         }
#       ]
#     }
#   ]

#   init = () ->
#     gse.fields = [
#       {
#         type: 'gradeScheme',
#         key: 'grade_scheme_elements',
#         templateOptions: {
#           btnText:'Add A Level',
#           fields: gse.fields
#         },
#         controller: ($scope) ->
#           # debugger
#       }
#     ]
#     return

#   gse.originalFields = angular.copy(gse.fields);

#   return
# ]
