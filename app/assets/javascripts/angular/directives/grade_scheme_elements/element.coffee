# Renders a single grade scheme element in the grade scheme element
# mass edit form
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  {
    scope:
      gradeSchemeElement: '='
      setFormIsInvalid: '&'
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
    link: (scope, element, attrs) ->
      scope.addElement = () ->
        GradeSchemeElementsService.addElement(@gradeSchemeElement)

      scope.removeElement = () ->
        GradeSchemeElementsService.removeElement(@gradeSchemeElement)
        scope.setValidity()

      scope.validateElements = () ->
        GradeSchemeElementsService.validateElements()
        scope.setValidity()

      # Sets the validity on the parent
      scope.setValidity = () ->
        result = _.find(GradeSchemeElementsService.gradeSchemeElements, (element) ->
          element.validationError?
        )
        @setFormIsInvalid()(result?)
  }
]
