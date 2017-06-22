# Shared logic for creating, editing, and otherwise interacting with GradeSchemeElements
@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', 'orderByFilter',
  ($http, GradeCraftAPI, orderBy) ->

    _deletedElementIds = []
    gradeSchemeElements = []
    _totalPoints = 0

    totalPoints = () ->
      _totalPoints

    # Iterate all elements to ensure that there are no direct point conflicts
    validateElements = () ->
      has_zero_threshold = false
      for element, i in gradeSchemeElements
        _validateElement(element)
        has_zero_threshold = true if element.lowest_points == 0
      addZeroThreshold() if not has_zero_threshold

    # Remove the current element from the collection and add to deleted_ids array
    removeElement = (currentElement) ->
      if currentElement.lowest_points == 0 && _isOnlyZeroThreshold(currentElement)
        currentElement.validationError = "Lowest level threshold must be 0"
      else
        _deletedElementIds.push(gradeSchemeElements.splice(gradeSchemeElements.indexOf(currentElement), 1)[0].id)

    # Add a new element after the selected element, if one was given
    addElement = (currentElement, attributes=null) ->
      if currentElement?
        for element, i in gradeSchemeElements
          if element == currentElement
            gradeSchemeElements.splice(i + 1, 0, _newElement())
            return
      else
        gradeSchemeElements.push(_newElement(attributes))

    # Add new element to represent zero threshold
    addZeroThreshold = () ->
      zeroElement = _newElement()
      zeroElement.level = "Not yet on the board"
      zeroElement.lowest_points = 0
      gradeSchemeElements.push(zeroElement)

    # Sorts the grade scheme elements by their point threshold
    sortElementsByPoints = () ->
      gradeSchemeElements = orderBy(gradeSchemeElements, 'lowest_points', true)

    # GET grade scheme elements for the current course
    # Returns a promise
    getGradeSchemeElements = () ->
      $http.get("/api/grade_scheme_elements").then((response) ->
        GradeCraftAPI.loadMany(gradeSchemeElements, response.data)
        _totalPoints = response.data.meta.total_points
        GradeCraftAPI.logResponse(response)
      )

    # POST grade scheme element updates
    # Optionally redirects to a specified url
    postGradeSchemeElements = (redirectUrl=null, validate=true, showAlert=false) ->
      return if gradeSchemeElements.length < 1 || (validate && !_hasValidPointThresholds())

      data = {
        grade_scheme_elements_attributes: gradeSchemeElements
        deleted_ids: _deletedElementIds
      }
      $http.put('/api/grade_scheme_elements', data).then(
        (response) ->
          _clearArray(gradeSchemeElements)
          GradeCraftAPI.loadMany(gradeSchemeElements, response.data)
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
          alert('Changes were successfully saved') if showAlert is true
        , (error) ->
          alert('An error occurred while saving changes')
          GradeCraftAPI.logResponse(error)
      )

    deleteGradeSchemeElements = (redirectUrl=null) ->
      $http.delete('/api/grade_scheme_elements/destroy_all').then(
        (response) ->
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
        , (error) ->
          alert('Failed to delete grade scheme elements')
          GradeCraftAPI.logResponse(error)
      )

    # Private

    # Ensure that there are no blank point thresholds
    _hasValidPointThresholds = () ->
      isValid = true
      for element in gradeSchemeElements
        if isNaN(element.lowest_points) || !element.lowest_points?
          element.validationError = "Point threshold cannot be blank"
          isValid = false
      isValid

    # Ensures that the current element does not have a point conflict with another
    _validateElement = (currentElement) ->
      currentElement.validationError = undefined

      if !currentElement.lowest_points?
        currentElement.validationError = "Point threshold does not have a value"

      for element in gradeSchemeElements
        continue if element == currentElement || !element.lowest_points? || isNaN(element.lowest_points)

        # Invalid because it is in direct conflict with another level
        if element.lowest_points == currentElement.lowest_points
          currentElement.validationError = "This level has the same point threshold as another level"

    # Checks if there are more than one zero threshold elements
    _isOnlyZeroThreshold = (currentElement) ->
      result = _.find(gradeSchemeElements, (element) ->
        currentElement != element && element.lowest_points == 0
      )?
      !result

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

    _clearArray = (array) ->
      array.length = 0

    {
      gradeSchemeElements: gradeSchemeElements
      removeElement: removeElement
      addElement: addElement
      addZeroThreshold: addZeroThreshold
      validateElements: validateElements
      sortElementsByPoints: sortElementsByPoints
      getGradeSchemeElements: getGradeSchemeElements
      postGradeSchemeElements: postGradeSchemeElements
      deleteGradeSchemeElements: deleteGradeSchemeElements
      totalPoints: totalPoints
    }
]
