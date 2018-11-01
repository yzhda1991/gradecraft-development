# Renders the hover icons that describe an assignment's unlock, lock conditions
#   as well as one to describe if it is group-graded
gradecraft.directive "assignmentDescriptorIcons", ["GradeCraftAPI", (GradeCraftAPI) ->
  AssignmentDescriptorIconsCtrl = [() ->
    vm = this
    vm.termFor = (term) -> GradeCraftAPI.termFor(term)
  ]

  {
    scope:
      assignment: "="
    bindToController: true
    controller: AssignmentDescriptorIconsCtrl
    controllerAs: "descriptorIconsCtrl"
    templateUrl: "assignments/descriptor_icons.html"
  }
]
