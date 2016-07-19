@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    elements = []
    deletedIds = []

    remove = (index) ->
      deletedIds.push(elements.splice(index, 1)[0].id)

    addNew = (index) ->
      elements.splice(index + 1, 0, {
        letter: ''
        level: ''
        lowest_points: ''
        highest_points: elements[index].lowest_points - 1
      })

    addFirst = () ->
      elements.push({
        letter: ''
        level: ''
        lowest_points: 0
        highest_points: 100
      })

    nextHighestElement = (index) ->
      return null if index == 0
      elements[index - 1]

    nextLowestElement = (index) ->
      return null if index == elements.length - 1
      elements[index + 1]

    checkLowRange = (value, index) ->
      (value < elements[parseInt(index)].highest_points)

    # update the grade scheme element immediately lower than the active one
    updateLowerElement = (activeElement, elementIndex, newValue) ->
      lowerElement = nextLowestElement(elementIndex)

      # if there's no lower element then there's nothing to update
      if lowerElement

        if (newValue < lowerElement.highest_points || lowerElement.highest_points == '')
          # index + 1 here gives us the next element in the array.
          # set its value to one less than the lowest_points value on
          # the active element.
          lowerElement.highest_points = newValue - 1
          true
        else
          false

      else
        true

    # update the grade scheme element immediately higher than the active one
    updateHigherElement = (index, newValue) ->
      higherElement = nextHighestElement(index)
      # don't update if we're changing the value on the first element
      if higherElement && newValue > higherElement.lowest_points
        # index - 1 gets us the higher element. set its value to one more
        # than the highest_points value on the active element
        higherElement.lowest_points = newValue + 1
        true
      else
        true

    getGradeSchemeElements = ()->
      $http.get('/grade_scheme_elements/mass_edit.json').success((response) ->
        angular.copy(response.grade_scheme_elements, elements)
      )

    postGradeSchemeElements = ()->
      data = {
        grade_scheme_elements_attributes: elements
        deleted_ids: deletedIds
      }
      $http.put('/grade_scheme_elements/mass_update', data).success(
        (data) ->
          angular.copy(data.grade_scheme_elements, elements)
          window.location.href = '/grade_scheme_elements/'
      ).error(
        (error) ->
          console.log(error)
      )

    return {
        getGradeSchemeElements: getGradeSchemeElements
        postGradeSchemeElements: postGradeSchemeElements
        checkLowRange: checkLowRange
        updateHigherElement: updateHigherElement
        updateLowerElement: updateLowerElement
        elements: elements
        remove: remove
        addNew: addNew
        addFirst: addFirst
        # update_scheme: update_scheme
    }

    # update_scheme = (index, newValue) ->
    #   if(index != elements.length-1)
    #     elements[index+1].highest_points = newValue-1

]
