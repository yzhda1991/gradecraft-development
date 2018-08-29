# Uses the GradeSchemeElementsService to aggregate a list of initialized levels
# for the initial setup process in a course
@gradecraft.factory 'GradeSchemeElementsSetupService', ['GradeSchemeElementsService', '$http', 'GradeCraftAPI',
  (GradeSchemeElementsService, $http, GradeCraftAPI) ->
    _standardGradeLetters = ['A', 'B', 'C', 'D', 'F']

    # Create the grade scheme elements
    postGradeSchemeElements = (isUsingGradeLetters, isUsingPlusMinusGrades, additionalLevels, redirectUrl=null) ->
      _addGradeLevels(isUsingPlusMinusGrades) if isUsingGradeLetters
      _addAdditionalLevels(additionalLevels) if additionalLevels? && additionalLevels > 0
      GradeSchemeElementsService.ensureHasZeroElement()
      _postGradeSchemeElements(redirectUrl)

    _postGradeSchemeElements = (redirectUrl) ->
      return if GradeSchemeElementsService.gradeSchemeElements.length < 1

      $http.put('/api/grade_scheme_elements/mass_update', grade_scheme_elements_attributes: GradeSchemeElementsService.gradeSchemeElements).then(
        (response) ->
          _clearArray(GradeSchemeElementsService.gradeSchemeElements)
          GradeCraftAPI.loadMany(GradeSchemeElementsService.gradeSchemeElements, response.data)
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
        , (error) ->
          alert('An error occurred while saving changes')
          GradeCraftAPI.logResponse(error)
      )

    # Add grade scheme elements with the preset parameters
    _addGradeLevels = (includePlusMinusGrades) ->
      _.each(_standardGradeLetters, (letter) ->
        GradeSchemeElementsService.addElement(null, { letter: letter + "+" }) if includePlusMinusGrades and letter != 'F'
        GradeSchemeElementsService.addElement(null, { letter: letter })
        GradeSchemeElementsService.addElement(null, { letter: letter + "-" }) if includePlusMinusGrades and letter not in ['D','F']
      )

    # Add additional levels
    _addAdditionalLevels = (numberOfLevels) ->
      _.times(numberOfLevels-1, () ->
        GradeSchemeElementsService.addElement()
      )
      # Make last element the zero threshold
      GradeSchemeElementsService.addZeroElement()

    _clearArray = (array) -> array.length = 0

    {
      postGradeSchemeElements: postGradeSchemeElements
    }
]
