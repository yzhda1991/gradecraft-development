# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  GradeSchemeElementsCtrl = [() ->
    vm = this

    vm.loading = true
    vm.grade_scheme_elements = null

    vm.addElement = () ->
      GradeSchemeElementsService.addElement()

    vm.postGradeSchemeElements = () ->
      GradeSchemeElementsService.postGradeSchemeElements()

    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      vm.loading = false
      vm.grade_scheme_elements = GradeSchemeElementsService.gradeSchemeElements
    )
  ]

  {
    bindToController: true
    controller: GradeSchemeElementsCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'grade_scheme_elements/main.html'
  }
]
