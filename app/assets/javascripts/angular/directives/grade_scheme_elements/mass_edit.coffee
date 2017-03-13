# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  GradeSchemeElementsCtrl = [() ->
    vm = this

    vm.loading = true
    vm.gradeSchemeElements = null
    vm.formIsInvalid = false

    # Add first element
    vm.addElement = () ->
      GradeSchemeElementsService.addElement()
      vm.formIsInvalid = true

    vm.postGradeSchemeElements = () ->
      GradeSchemeElementsService.postGradeSchemeElements().then(() ->
        window.location.href = '/grade_scheme_elements/'
      )

    vm.setFormIsInvalid = (value) ->
      vm.formIsInvalid = value

    GradeSchemeElementsService.getGradeSchemeElements().then(() ->
      vm.loading = false
      vm.gradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements
      GradeSchemeElementsService.validateElements()
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
