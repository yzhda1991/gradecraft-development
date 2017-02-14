# Renders a single grade scheme element in the grade scheme element mass edit
# form
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', (GradeSchemeElementsService)->

  GradeSchemeElementCtrl = [()->
    vm = this

    vm.addNew = (index)->
      GradeSchemeElementsService.addNew(index)
      
    vm.remove = (index)->
      GradeSchemeElementsService.remove(index)
  ]

  {
    bindToController: true
    controller: GradeSchemeElementCtrl
    controllerAs: 'vm'
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
  }
]
