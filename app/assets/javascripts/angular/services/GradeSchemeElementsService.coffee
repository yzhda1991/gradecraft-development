@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  gradeSchemeElements = []
  _totalPoints  = 0

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
      continue if angular.equals(element, currentElement) || !element.lowest_points?

      # Invalid because it is in direct conflict with another level
      if element.lowest_points == currentElement.lowest_points
        currentElement.validationError = "This level has the same point threshold as another level."

      # Invalid because it is within one point of another level
      if element.lowest_points - 1 == currentElement.lowest_points ||
          element.lowest_points + 1 == currentElement.lowest_points
        currentElement.validationError = "This level is within one point of another level."

  newElement = () ->
    {
      letter: null
      level: null
      lowest_points: null
    }

  removeElement = (currentElement) ->
    gradeSchemeElements.splice(gradeSchemeElements.indexOf(currentElement), 1)
    validateElements()

  addElement = (currentElement) ->
    if currentElement?
      for element, i in gradeSchemeElements
        if angular.equals(element, currentElement)
          gradeSchemeElements.splice(i + 1, 0, newElement())
          return
    else
      gradeSchemeElements.push(newElement())

  addZeroThreshold = () ->
    zeroElement = newElement()
    zeroElement.level = "Not yet defined"
    zeroElement.lowest_points = 0
    gradeSchemeElements.push(zeroElement)
    validateElements()  # ensure zero threshold does not conflict with existing

  getGradeSchemeElements = () ->
    $http.get("/api/grade_scheme_elements").success((response) ->
      GradeCraftAPI.loadMany(gradeSchemeElements, response)
      _totalPoints = response.meta.total_points
      GradeCraftAPI.logResponse(response)
    )

  postGradeSchemeElements = () ->
    data = {
      grade_scheme_elements_attributes: gradeSchemeElements
    }

    # Ensure a zero-level
    thresholds = (element.lowest_points for element in gradeSchemeElements)
    if 0 in thresholds
      $http.put('/grade_scheme_elements/mass_update', data).success(
        (data) ->
          angular.copy(data.grade_scheme_elements, gradeSchemeElements)
          window.location.href = '/grade_scheme_elements/'
          GradeCraftAPI.logResponse(data)
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
