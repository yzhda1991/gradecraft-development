# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm',
['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  GradeSchemeElementsCtrl = [() ->
    vm = this

    vm.loading = true
    vm.gradeSchemeElements = null

    # Add first element
    vm.addElement = () ->
      GradeSchemeElementsService.addElement()

    vm.postGradeSchemeElements = () ->
      GradeSchemeElementsService.postGradeSchemeElements('/grade_scheme_elements/')

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
    link: (scope, element, attrs, ctrl) ->
      # For manually triggering form validation by child directives
      ctrl.updateFormValidity = () ->
        _.each(ctrl.gradeSchemeElements, (element, index) ->
          scope.gradeSchemeElementsForm["point_threshold_#{index}"].$setValidity('validPointThreshold', !element.validationError?)
        )
  }
]
