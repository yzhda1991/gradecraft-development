@gradecraft.directive "descriptorIcon", [() ->
  DescriptorIconCtrl = [() -> 
    vm = this
    vm.iconClass = "fa-" + vm.icon
  ]

  {
    scope:
      icon: "@"
    bindToController: true
    controller: DescriptorIconCtrl
    controllerAs: "descriptorIconCtrl"
    templateUrl: "assignments/descriptor_icon.html"
    transclude: true
  }
]
