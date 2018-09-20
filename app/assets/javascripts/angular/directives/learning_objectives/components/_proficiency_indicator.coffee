@gradecraft.directive "loProficiencyIndicator", [() ->
  LOProficiencyIndicatorCtrl = [() ->
    vm = this
    vm.gradePath = "/grades/#{@observedOutcome.grade_id}"
  ]

  {
    scope:
      observedOutcome: "="
    bindToController: true
    controller: LOProficiencyIndicatorCtrl
    controllerAs: "indicatorCtrl"
    templateUrl: "learning_objectives/components/_proficiency_indicator.html"
  }
]
