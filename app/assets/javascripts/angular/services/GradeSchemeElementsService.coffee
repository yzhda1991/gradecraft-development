@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  deletedElementIds = []
  gradeSchemeElements = []
  _totalPoints = 0

  totalPoints = () ->
    _totalPoints

  validateElements = () ->
    has_zero_threshold = false
    for element, i in gradeSchemeElements
      validateElement(element)
      has_zero_threshold = true if element.lowest_points == 0
    addZeroThreshold() if not has_zero_threshold

  validateElement = (currentElement) ->
    currentElement.validationError = undefined
    for element in gradeSchemeElements
      continue if element == currentElement || !element.lowest_points?

      # Invalid because it is in direct conflict with another level
      if element.lowest_points == currentElement.lowest_points
        currentElement.validationError = "This level has the same point threshold as another level."

      # Invalid because it is within one point of another level
      if element.lowest_points - 1 == currentElement.lowest_points ||
          element.lowest_points + 1 == currentElement.lowest_points
        currentElement.validationError = "This level is within one point of another level."

  removeElement = (currentElement) ->
    if currentElement.lowest_points == 0 && isOnlyZeroThreshold(currentElement)
      currentElement.validationError = "Lowest level threshold must be 0"
    else
      deletedElementIds.push(gradeSchemeElements.splice(gradeSchemeElements.indexOf(currentElement), 1)[0].id)
      validateElements() if gradeSchemeElements.length > 0

  addElement = (currentElement) ->
    if currentElement?
      for element, i in gradeSchemeElements
        if element == currentElement
          gradeSchemeElements.splice(i + 1, 0, _newElement())
          return
    else
      gradeSchemeElements.push(_newElement())

  # Create new empty grade scheme element object
  _newElement = () ->
    angular.copy({
      letter: null
      level: null
      lowest_points: null
    })

  addZeroThreshold = () ->
    zeroElement = _newElement()
    zeroElement.level = "Not yet defined"
    zeroElement.lowest_points = 0
    gradeSchemeElements.push(zeroElement)
    validateElements()  # ensure zero threshold does not conflict with existing

  isOnlyZeroThreshold = (currentElement) ->
    result = _.find(gradeSchemeElements, (element) ->
      currentElement != element && element.lowest_points == 0
    )?
    !result

  getGradeSchemeElements = () ->
    $http.get("/api/grade_scheme_elements").success((response) ->
      GradeCraftAPI.loadMany(gradeSchemeElements, response)
      _totalPoints = response.meta.total_points
      GradeCraftAPI.logResponse(response)
    )

  postGradeSchemeElements = () ->
    data = {
      grade_scheme_elements_attributes: gradeSchemeElements
      deleted_ids: deletedElementIds
    }

    # Ensure a zero-level
    thresholds = (element.lowest_points for element in gradeSchemeElements)
    if 0 in thresholds
      $http.put('/grade_scheme_elements/mass_update', data).success(
        (data) ->
          angular.copy(data.grade_scheme_elements, gradeSchemeElements)
          GradeCraftAPI.logResponse(data)
          window.location.href = '/grade_scheme_elements/'
      ).error(
        (error) ->
          alert('An error occurred that prevented saving.')
          GradeCraftAPI.logResponse(error)
      )
    else
      alert('A level with a Point Threshold of 0 (zero) is required.')

  {
    gradeSchemeElements: gradeSchemeElements
    removeElement: removeElement
    addElement: addElement
    validateElement: validateElement
    validateElements: validateElements
    getGradeSchemeElements: getGradeSchemeElements
    postGradeSchemeElements: postGradeSchemeElements
    totalPoints: totalPoints
  }
]
