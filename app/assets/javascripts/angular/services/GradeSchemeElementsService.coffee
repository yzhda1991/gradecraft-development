@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  deletedElementIds = []
  gradeSchemeElements = []
  _totalPoints = 0

  totalPoints = () ->
    _totalPoints

  # Ensure that there are no blank point thresholds
  hasValidPointThresholds = () ->
    isValid = true
    for element in gradeSchemeElements
      if isNaN(element.lowest_points) || !element.lowest_points?
        element.validationError = "Point threshold cannot be blank"
        isValid = false
    isValid

  # Iterate all elements to ensure that there are no direct point conflicts
  validateElements = () ->
    has_zero_threshold = false
    for element, i in gradeSchemeElements
      validateElement(element)
      has_zero_threshold = true if element.lowest_points == 0
    addZeroThreshold() if not has_zero_threshold

  # Ensures that the current element does not have a point conflict with another
  validateElement = (currentElement) ->
    currentElement.validationError = undefined
    for element in gradeSchemeElements
      continue if element == currentElement || !element.lowest_points? || isNaN(element.lowest_points)

      # Invalid because it is in direct conflict with another level
      if element.lowest_points == currentElement.lowest_points
        currentElement.validationError = "This level has the same point threshold as another level"

  # Remove the current element from the collection and add to deleted_ids array
  removeElement = (currentElement) ->
    if currentElement.lowest_points == 0 && isOnlyZeroThreshold(currentElement)
      currentElement.validationError = "Lowest level threshold must be 0"
    else
      deletedElementIds.push(gradeSchemeElements.splice(gradeSchemeElements.indexOf(currentElement), 1)[0].id)
      validateElements() if gradeSchemeElements.length > 0

  # Add a new element after the selected element, if one was given
  addElement = (currentElement, attributes=null) ->
    if currentElement?
      for element, i in gradeSchemeElements
        if element == currentElement
          gradeSchemeElements.splice(i + 1, 0, _newElement())
          return
    else
      gradeSchemeElements.push(_newElement(attributes))

  # New empty grade scheme element object
  _newElement = (attributes=null) ->
    element = angular.copy({
      letter: null
      level: null
      lowest_points: null
    })
    angular.forEach(attributes, (value, key) ->
      element[key] = value
    ) if attributes?
    element

  # Add new element to represent zero threshold
  addZeroThreshold = () ->
    zeroElement = _newElement()
    zeroElement.level = "Not yet on the board"
    zeroElement.lowest_points = 0
    gradeSchemeElements.push(zeroElement)

  # Checks if there are more than one zero threshold elements
  isOnlyZeroThreshold = (currentElement) ->
    result = _.find(gradeSchemeElements, (element) ->
      currentElement != element && element.lowest_points == 0
    )?
    !result

  # GET grade scheme elements for the current course
  getGradeSchemeElements = () ->
    $http.get("/api/grade_scheme_elements").success((response) ->
      GradeCraftAPI.loadMany(gradeSchemeElements, response)
      _totalPoints = response.meta.total_points
      GradeCraftAPI.logResponse(response)
    )

  # POST grade scheme element updates
  postGradeSchemeElements = (validate=true) ->
    return if validate && !hasValidPointThresholds()
    data = {
      grade_scheme_elements_attributes: gradeSchemeElements
      deleted_ids: deletedElementIds
    }
    $http.put('/grade_scheme_elements/mass_update', data).success(
      (data) ->
        angular.copy(data.grade_scheme_elements, gradeSchemeElements)
        GradeCraftAPI.logResponse(data)
    ).error(
      (error) ->
        alert('An error occurred that prevented saving.')
        GradeCraftAPI.logResponse(error)
    )

  {
    gradeSchemeElements: gradeSchemeElements
    removeElement: removeElement
    addElement: addElement
    validateElements: validateElements
    getGradeSchemeElements: getGradeSchemeElements
    postGradeSchemeElements: postGradeSchemeElements
    totalPoints: totalPoints
  }
]
