# Uses the GradeSchemeElementsService to aggregate a list of initialized levels
# for the initial setup process in a course
@gradecraft.factory 'GradeSchemeElementsSetupService', ['GradeSchemeElementsService', (GradeSchemeElementsService) ->
  standardGradeLetters = ['A', 'B', 'C', 'D', 'E', 'F']

  # Add grade scheme elements with the preset parameters
  addGradeLevels = (includePlusMinusGrades) ->
    _.each(standardGradeLetters, (letter) ->
      GradeSchemeElementsService.addElement(null, { letter: letter + "+" }) if includePlusMinusGrades
      GradeSchemeElementsService.addElement(null, { letter: letter })
      GradeSchemeElementsService.addElement(null, { letter: letter + "-" }) if includePlusMinusGrades
    )

  # Add additional levels
  addAdditionalLevels = (numberOfLevels) ->
    _.times(numberOfLevels-1, () ->
      GradeSchemeElementsService.addElement()
    )
    # Make last element the zero threshold
    GradeSchemeElementsService.addZeroThreshold()

  # Create the grade scheme elements
  postGradeSchemeElements = (isUsingGradeLetters, isUsingPlusMinusGrades, addLevelsBelowF, levelsBelowF) ->
    addGradeLevels(isUsingPlusMinusGrades) if isUsingGradeLetters
    addAdditionalLevels(levelsBelowF) if addLevelsBelowF
    GradeSchemeElementsService.postGradeSchemeElements(false)

  {
    postGradeSchemeElements: postGradeSchemeElements
  }
]
