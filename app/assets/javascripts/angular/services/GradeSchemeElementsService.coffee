# Shared logic for creating, editing, and otherwise interacting with GradeSchemeElements
@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', 'orderByFilter',
  ($http, GradeCraftAPI, orderBy) ->

    gradeSchemeElements = []
    _totalPoints = 0

    totalPoints = () -> _totalPoints

    removeElement = (currentElement) ->
      if currentElement.lowest_points == 0 && _isOnlyZeroThreshold(currentElement)
        currentElement.validationError = "Lowest level threshold must be 0"
      else
        if currentElement.id?
          _deleteElement(currentElement)
        else
          gradeSchemeElements.splice(gradeSchemeElements.indexOf(currentElement), 1)

    # Add a new element after the selected element, if one was given
    addElement = (currentElement, attributes=null) ->
      if currentElement?
        for element, i in gradeSchemeElements
          if element == currentElement
            gradeSchemeElements.splice(i + 1, 0, newElement())
            return
      else
        gradeSchemeElements.push(newElement(attributes))

    ensureHasZeroElement = () ->
      hasZeroElement = _.some(gradeSchemeElements, (element) -> element.lowest_points == 0)
      addZeroElement() if not hasZeroElement

    # GET grade scheme elements for the current course
    # Returns a promise
    getGradeSchemeElements = () ->
      $http.get("/api/grade_scheme_elements").then((response) ->
        GradeCraftAPI.loadMany(gradeSchemeElements, response.data)
        _totalPoints = response.data.meta.total_points
        GradeCraftAPI.logResponse(response)
      )

    createOrUpdate = (element, successCallback=null, failureCallback=null) ->
      if element.id?
        updateGradeSchemeElement(element, successCallback, failureCallback)
      else
        createGradeSchemeElement(element, successCallback, failureCallback)

    createGradeSchemeElement = (element, successCallback=null, failureCallback=null) ->
      $http.post("/api/grade_scheme_elements", grade_scheme_element: element).then(
        (response) ->
          GradeCraftAPI.loadItem(element, "grade_scheme_elements", response.data)
          successCallback() if successCallback?
          GradeCraftAPI.logResponse(response)
        , (error) ->
          alert('An error occurred while saving changes')
          failureCallback() if failureCallback?
          GradeCraftAPI.logResponse(error)
      )

    updateGradeSchemeElement = (element, successCallback=null, failureCallback=null) ->
      $http.put("/api/grade_scheme_elements/#{element.id}", grade_scheme_element: element).then(
        (response) ->
          GradeCraftAPI.loadItem(element, "grade_scheme_elements", response.data)
          successCallback() if successCallback?
          GradeCraftAPI.logResponse(response)
        , (error) ->
          alert('An error occurred while saving changes')
          failureCallback() if failureCallback?
          GradeCraftAPI.logResponse(error)
      )

    deleteAll = (redirectUrl=null) ->
      $http.delete('/api/grade_scheme_elements/destroy_all').then(
        (response) ->
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
        , (error) ->
          alert('Failed to delete grade scheme elements')
          GradeCraftAPI.logResponse(error)
      )

    ## Private

    # Ensures that the current element does not have a point conflict with another
    validateElement = (currentElement) ->
      currentElement.validationError = undefined

      if !currentElement.lowest_points?
        currentElement.validationError = "Point threshold does not have a value"

      for element in gradeSchemeElements
        continue if element == currentElement || !element.lowest_points? || isNaN(element.lowest_points)

        # Invalid because it is in direct conflict with another level
        if element.lowest_points == currentElement.lowest_points
          currentElement.validationError = "This level has the same point threshold as another level"

    # New empty grade scheme element object
    newElement = (attributes=null) ->
      element = angular.copy({
        letter: null
        level: null
        lowest_points: null
      })
      angular.forEach(attributes, (value, key) ->
        element[key] = value
      ) if attributes?
      element

    addZeroElement = () ->
      zeroElement = newElement()
      zeroElement.level = "Not yet on the board"
      zeroElement.lowest_points = 0
      gradeSchemeElements.push(zeroElement)

    # Checks if there are more than one zero threshold elements
    _isOnlyZeroThreshold = (currentElement) ->
      result = _.find(gradeSchemeElements, (element) ->
        currentElement != element && element.lowest_points == 0
      )?
      !result

    _deleteElement = (element) ->
      $http.delete("/api/grade_scheme_elements/#{element.id}").then(
        (response) ->
          GradeCraftAPI.deleteItem(gradeSchemeElements, element)
          alert("Successfully deleted #{element.name || 'grade scheme element'}")
          GradeCraftAPI.logResponse(response)
        , (error) ->
          alert('Failed to delete grade scheme element')
          GradeCraftAPI.logResponse(error)
      )

    {
      gradeSchemeElements: gradeSchemeElements
      ensureHasZeroElement: ensureHasZeroElement
      removeElement: removeElement
      addElement: addElement
      newElement: newElement
      addZeroElement: addZeroElement
      validateElement: validateElement
      createOrUpdate: createOrUpdate
      getGradeSchemeElements: getGradeSchemeElements
      updateGradeSchemeElement: updateGradeSchemeElement
      deleteAll: deleteAll
      totalPoints: totalPoints
    }
]
