# Renders a single grade scheme element in the grade scheme element
# mass edit form
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  {
    scope:
      gradeSchemeElement: '='
      updateFormValidity: '&'
      index: '@'
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
    link: (scope, element, attrs) ->
      scope.addElement = () ->
        GradeSchemeElementsService.addElement(@gradeSchemeElement)

      scope.removeElement = () ->
        GradeSchemeElementsService.removeElement(@gradeSchemeElement)
        @updateFormValidity()

      scope.validateElements = () ->
        GradeSchemeElementsService.validateElements()
        @updateFormValidity()
  }
]
