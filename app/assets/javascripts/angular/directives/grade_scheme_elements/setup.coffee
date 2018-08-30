# Main entry point for rendering and handling the initial GSE setup questions
@gradecraft.directive 'gradeSchemeElementsSetup',
['GradeSchemeElementsSetupService', (GradeSchemeElementsSetupService) ->
  GradeSchemeElementsSetupCtrl = [() ->
    vm = this
    vm.showSetup = true

    vm.isUsingGradeLetters = undefined
    vm.isUsingPlusMinusGrades = undefined
    vm.addLevelsBelowF = undefined
    vm.additionalLevels = undefined

    vm.setUpGradeSchemeElements = () ->
      GradeSchemeElementsSetupService.setUpGradeSchemeElements(
        vm.isUsingGradeLetters,
        vm.isUsingPlusMinusGrades,
        vm.additionalLevels
      )
      vm.showSetup = false
  ]

  {
    bindToController: true
    controller: GradeSchemeElementsSetupCtrl
    controllerAs: 'gseSetupCtrl'
    restrict: 'EA'
    templateUrl: 'grade_scheme_elements/setup.html'
  }
]
