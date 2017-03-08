# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  GradeSchemeElementsCtrl = [() ->
    vm = this

    vm.loading = true
    vm.gradeSchemeElements = null
    vm.hasInvalidElements = false

    vm.addElement = () ->
      GradeSchemeElementsService.addElement()

    vm.postGradeSchemeElements = () ->
      GradeSchemeElementsService.postGradeSchemeElements().then(() ->
        window.location.href = '/grade_scheme_elements/'
      )

    vm.setHasInvalidElements = (value) ->
      vm.hasInvalidElements = value

    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      vm.loading = false
      vm.gradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements
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
