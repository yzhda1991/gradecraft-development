# Renders a single grade scheme element in the grade scheme element
# mass edit form
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  {
    scope:
      gradeSchemeElement: '='
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
    link: (scope, element, attrs) ->
      scope.addElement = () ->
        GradeSchemeElementsService.addElement(@gradeSchemeElement)

      scope.removeElement = () ->
        GradeSchemeElementsService.removeElement(@gradeSchemeElement)

      scope.validateElements = () ->
        GradeSchemeElementsService.validateElements()
  }
]
