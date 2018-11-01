# Uses the GradeSchemeElementsService to aggregate a list of initialized levels
# for the initial setup process in a course
gradecraft.factory 'GradeSchemeElementsSetupService', ['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  standardGradeLetters = ['A', 'B', 'C', 'D', 'F']

  # Add grade scheme elements with the preset parameters
  _addGradeLevels = (includePlusMinusGrades) ->
    _.each(standardGradeLetters, (letter) ->
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
    GradeSchemeElementsService.addZeroThreshold()

  # Create the grade scheme elements
  postGradeSchemeElements = (isUsingGradeLetters, isUsingPlusMinusGrades, additionalLevels, redirectUrl=null) ->
    _addGradeLevels(isUsingPlusMinusGrades) if isUsingGradeLetters
    _addAdditionalLevels(additionalLevels) if additionalLevels? && additionalLevels > 0
    GradeSchemeElementsService.postGradeSchemeElements(redirectUrl, false)

  {
    postGradeSchemeElements: postGradeSchemeElements
  }
]
