# Shared logic for creating, editing, and otherwise interacting with GradeSchemeElements
@gradecraft.factory 'GradeSchemeElementsService', ['$http', 'GradeCraftAPI', 'orderByFilter',
  ($http, GradeCraftAPI, orderBy) ->

    gradeSchemeElements = []
    _totalPoints = 0

    totalPoints = () -> _totalPoints

    # Remove the current element from the collection and add to deleted_ids array
    removeElement = (currentElement) ->
      if currentElement.lowest_points == 0 && _isOnlyZeroThreshold(currentElement)
        currentElement.validationError = "Lowest level threshold must be 0"
      else
        console.log("delete") # TODO

    # Add a new element after the selected element, if one was given
    addElement = (currentElement, attributes=null) ->
      if currentElement?
        for element, i in gradeSchemeElements
          if element == currentElement
            gradeSchemeElements.splice(i + 1, 0, newElement())
            return
      else
        gradeSchemeElements.push(newElement(attributes))

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

    postGradeSchemeElement = (element, successCallback=null, failureCallback=null) ->
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

    # Checks if there are more than one zero threshold elements
    _isOnlyZeroThreshold = (currentElement) ->
      result = _.find(gradeSchemeElements, (element) ->
        currentElement != element && element.lowest_points == 0
      )?
      !result

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

    {
      gradeSchemeElements: gradeSchemeElements
      removeElement: removeElement
      addElement: addElement
      newElement: newElement
      validateElement: validateElement
      sortElementsByPoints: sortElementsByPoints
      getGradeSchemeElements: getGradeSchemeElements
      postGradeSchemeElement: postGradeSchemeElement
      deleteGradeSchemeElements: deleteGradeSchemeElements
      totalPoints: totalPoints
    }
]
