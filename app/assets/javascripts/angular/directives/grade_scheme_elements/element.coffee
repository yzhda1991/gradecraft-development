# Renders a single grade scheme element in the grade scheme element
# mass edit form
@gradecraft.directive 'gradeSchemeElement', ['GradeSchemeElementsService', (GradeSchemeElementsService)->
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
    restrict: 'EA'
    require: 'ngModel'
    link: (scope, element, attrs, modelCtrl)->
      scope.validateElements = ()->
        for element, i in gseFormCtrl.grade_scheme_elements
          scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('directConflict', true)
          scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('nearConflict', true)
          for otherElement, j in gseFormCtrl.grade_scheme_elements
            continue if i == j

            if element.lowest_points == otherElement.lowest_points
              # Invalid because it is in direct conflict with another level
              scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('directConflict', false)
              scope.gradeSchemeForm["lowest_points_#{j}"].$setValidity('directConflict', false)

            if (element.lowest_points - 1 == otherElement.lowest_points ||
                element.lowest_points + 1 == otherElement.lowest_points)
              # Invalid because it is within one point of another level
              scope.gradeSchemeForm["lowest_points_#{i}"].$setValidity('nearConflict', false)
              scope.gradeSchemeForm["lowest_points_#{j}"].$setValidity('nearConflict', false)
  }
]
# require: ['^^gradeSchemeElementsMassEditForm', 'ngModel']
