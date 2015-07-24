@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    generateFormModels(response.grade_scheme_elements)

  generateFormModels = (grade_scheme_elements) ->
    gse.model.grade_scheme_elements = grade_scheme_elements.slice().reverse()
    init()

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
        key: 'low_range',
        templateOptions: {
          label: 'Low Range',
          required: true
        }
      },
      {
        className: 'small-12 medium-2 columns',
        type: 'input',
        key: 'high_range',
        templateOptions: {
          label: 'High Range',
          required: true
        }
      }
      ,{
        type: 'button',
        className: "remove-element button alert radius .small-12 medium-2 columns",
        templateOptions: {
          text: 'Remove',
          onClick: ($event) ->
            alert('foo!')
        }
      }
    ]
  }
      # / %button{:type => 'button', :class => 'remove-element button alert radius', 'ng-click' => 'model[options.key].splice($index, 1)'} Remove

  init = () ->
    gse.fields = [
      {
        type: 'gradeScheme',
        key: 'grade_scheme_elements',
        templateOptions: {
          btnText:'Add A Level',
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
