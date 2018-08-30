# Main entry point for mass editing grade scheme elements for a course
# Renders the appropriate form
@gradecraft.directive 'gradeSchemeElementsMassEditForm', ['GradeSchemeElementsService', 'orderByFilter',
  (GradeSchemeElementsService, orderBy) ->
    GradeSchemeElementsCtrl = [() ->
      vm = this
      vm.loading = true

      vm.addElement = () -> GradeSchemeElementsService.addElement()

      vm.deleteAll = () ->
        if confirm "Are you sure you want to delete all grade scheme elements?"
          GradeSchemeElementsService.deleteAll('/grade_scheme_elements/')

      # For manually triggering form validation by child directives
      vm.updateFormValidity = () ->
        _.each(GradeSchemeElementsService.gradeSchemeElements, (element) ->
          if vm.gradeSchemeElementsForm["point_threshold_#{element.order}"]?
            vm.gradeSchemeElementsForm["point_threshold_#{element.order}"].$setValidity('validPointThreshold', !element.validationError?)
        )

      GradeSchemeElementsService.getGradeSchemeElements().then(() -> vm.loading = false)
    ]

    {
      bindToController: true
      controller: GradeSchemeElementsCtrl
      controllerAs: 'vm'
      restrict: 'EA'
      templateUrl: 'grade_scheme_elements/main.html'
      link: (scope, element, attrs) ->
        scope.gradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements
        scope.sortElements = () -> scope.gradeSchemeElements = orderBy(scope.gradeSchemeElements, "lowest_points", true)
    }
]
