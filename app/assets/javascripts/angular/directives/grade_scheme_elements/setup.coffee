# Main entry point for rendering and handling the initial GSE setup questions
@gradecraft.directive 'gradeSchemeElementsSetup',
['GradeSchemeElementsSetupService', (GradeSchemeElementsSetupService) ->
  GradeSchemeElementsSetupCtrl = [() ->
    vm = this

    vm.isUsingGradeLetters = undefined
    vm.isUsingPlusMinusGrades = undefined
    vm.addLevelsBelowF = undefined
    vm.levelsBelowF = undefined

    vm.postGradeSchemeElements = () ->
      GradeSchemeElementsSetupService.postGradeSchemeElements(
        vm.isUsingGradeLetters,
        vm.isUsingPlusMinusGrades,
        vm.addLevelsBelowF,
        vm.levelsBelowF).then(() ->
        window.location.href = '/grade_scheme_elements/mass_edit'
      )
  ]

  {
    bindToController: true
    controller: GradeSchemeElementsSetupCtrl
    controllerAs: 'vm'
    restrict: 'EA'
    templateUrl: 'grade_scheme_elements/setup.html'
  }
]
