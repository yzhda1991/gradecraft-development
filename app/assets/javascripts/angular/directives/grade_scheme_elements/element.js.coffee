# Renders a single grade scheme element in the grade scheme element mass edit
# form
@gradecraft.directive 'gradeSchemeElement', [()->
  {
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
  }
]
