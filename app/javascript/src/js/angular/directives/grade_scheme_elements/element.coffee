# Renders a single grade scheme element in the grade scheme element mass edit form
# Note: This directive can exist only as a child of the gradeSchemeElementsMassEditForm
@gradecraft.directive 'gradeSchemeElement',
['GradeSchemeElementsService', 'DebounceQueue', '$timeout', (GradeSchemeElementsService, DebounceQueue, $timeout) ->
  {
    scope:
      gradeSchemeElement: '='
      index: '='
    require: '^^gradeSchemeElementsMassEditForm'
    templateUrl: 'grade_scheme_elements/element.html'
    restrict: 'E'
    link: (scope, element, attrs, gseForm) ->
      _validateElements = () ->
        GradeSchemeElementsService.validateElements()
        gseForm.updateFormValidity()

      _clearAlert = () ->
        $timeout(() ->
          scope.status = null
        , 3000)

      _save = (scope, showAlert) ->
        # Ensure that the current state is still valid
        _validateElements()
        return if gseForm.gradeSchemeElementsForm.$invalid

        scope.status = 'saving'
        GradeSchemeElementsService.postGradeSchemeElements(null, true, showAlert).then(() ->
          scope.status = 'saved'
        ).finally(() ->
          _clearAlert()
        )

      scope.status = undefined

      scope.addElement = () ->
        GradeSchemeElementsService.addElement(@gradeSchemeElement)

      scope.removeElement = () ->
        GradeSchemeElementsService.removeElement(@gradeSchemeElement)
        _validateElements()
        scope.persistChanges(true) if not @gradeSchemeElement.validationError?

      scope.persistChanges = (isRemoval=false) ->
        _validateElements()
        return if gseForm.gradeSchemeElementsForm.$invalid

        DebounceQueue.addEvent(
          'gradeSchemeElement', 'saveChanges', _save, [scope, isRemoval], 4000
        )

      # If lowest_points changes, reorder the elements accordingly
      scope.$watch('lowest_points', (newValue, oldValue) ->
        GradeSchemeElementsService.sortElementsByPoints() if newValue != oldValue
      )
  }
]
