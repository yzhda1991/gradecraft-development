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
        lowest_points: ''
        highest_points: ''
      })

    checkLowRange = (value, index) ->
      (value < elements[parseInt(index)].highest_points)

    # update the grade scheme element immediately lower than the active one
    updateLowerElement = (index, newValue) ->
      # don't update if we're changing the value on the last element
      if (index != elements.length - 1)
        # index + 1 here gives us the next element in the array.
        # set its value to one less than the lowest_points value on
        # the active element.
        elements[index + 1].highest_points = newValue - 1

    # this method will update the previous grade scheme element in the
    # collection if its lowest_points value is lower than the highest points
    # value for the previous element
    #
    updatePreviousElementIfLower = (element, index, modelValue) ->
      if (modelValue < element.highest_points || element.highest_points == '')
        updateLowerElement(index, modelValue)
        true
      else
        false

    # update the grade scheme element immediately higher than the active one
    updateHigherElement = (index, newValue) ->
      # don't update if we're changing the value on the first element
      if (index != 0)
        # index - 1 gets us the higher element. set its value to one more
        # than the highest_points value on the active element
        elements[index - 1].lowest_points = newValue + 1

    # this method will update the subsequent grade scheme element in the
    # collection if its highest_points value is greater than the lowest points
    # value for the subsequent element
    #
    updateNextElementIfHigher = (element, index, modelValue) ->
      if (modelValue > element.lowest_points)
        updateHigherElement(index, modelValue)
        true
      else
        false

    update_scheme = (index, newValue) ->
      if(index != elements.length-1)
        elements[index+1].highest_points = newValue-1

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
        updatePreviousElementIfLower: updatePreviousElementIfLower
        updateNextElementIfHigher: updateNextElementIfHigher
        elements: elements
        remove: remove
        addNew: addNew
        addFirst: addFirst
        update_scheme: update_scheme
    }
]
