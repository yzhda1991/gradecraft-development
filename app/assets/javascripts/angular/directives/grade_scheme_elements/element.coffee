# Renders a single grade scheme element in the grade scheme element mass edit form
# Note: This directive can exist only as a child of the gradeSchemeElementsMassEditForm
@gradecraft.directive "gradeSchemeElement", ["GradeSchemeElementsService", "$timeout",
  (GradeSchemeElementsService, $timeout) ->
    {
      scope:
        gradeSchemeElement: "="
        index: "="
      require: "^^gradeSchemeElementsMassEditForm"
      templateUrl: "grade_scheme_elements/element.html"
      restrict: "E"
      link: (scope, element, attrs, gseForm) ->
        scope.status = undefined

        scope.addElement = () -> GradeSchemeElementsService.addElement(@gradeSchemeElement)
        scope.removeElement = () -> GradeSchemeElementsService.removeElement(@gradeSchemeElement)

        scope.persistChanges = (isRemoval=false) ->
          scope.status = null
          GradeSchemeElementsService.validateElement(@gradeSchemeElement)
          gseForm.updateFormValidity()
          _save(scope, isRemoval)

        _clearAlert = () ->
          $timeout(() ->
            scope.status = null
          , 3000)

        _save = (scope, showAlert) ->
          return if scope.gradeSchemeElement.validationError?

          scope.status = "saving"
          GradeSchemeElementsService.createOrUpdate(
            scope.gradeSchemeElement,
            () => scope.status = "saved",
            () => scope.status = "failed"
          ).finally(() ->
            _clearAlert()
          )
    }
]
