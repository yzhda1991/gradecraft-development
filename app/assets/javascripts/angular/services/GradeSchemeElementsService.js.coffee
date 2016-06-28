@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    elements = []
    deletedIds = []
    totalPoints = null

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

    update_high_range = (index, newValue) ->
      if(index != elements.length - 1)
        elements[index + 1].highest_points = newValue-1

    update_low_range = (index, newValue) ->
      if(index != elements.length + 1)
        elements[index - 1].lowest_points = newValue+1

    # this method will update the previous grade scheme element in the
    # collection if its lowest_points value is lower than the highest points
    # value for the previous element
    #
    updatePreviousElementIfLower = (element, index, modelValue) ->
      if (modelValue < element.highest_points || element.highest_points == '')
        update_high_range(index, modelValue)
        true
      else
        false

    # this method will update the subsequent grade scheme element in the
    # collection if its highest_points value is greater than the lowest points
    # value for the subsequent element
    #
    updateNextElementIfHigher = (element, index, modelValue) ->
      if (modelValue > element.lowest_points || element.lowest_points == '' )
        update_low_range(index, modelValue)
        true
      else
        false

    getGradeSchemeElements = ()->
      $http.get('/grade_scheme_elements/mass_edit.json').success((response) ->
        angular.copy(response.grade_scheme_elements, elements)
        totalPoints = response.total_points
      )

    getTotalPoints = ->
      totalPoints

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
        update_high_range: update_high_range
        update_low_range: update_low_range
        updatePreviousElementIfLower: updatePreviousElementIfLower
        updateNextElementIfHigher: updateNextElementIfHigher
        getTotalPoints: getTotalPoints
        elements: elements
        remove: remove
        addNew: addNew
        addFirst: addFirst
    }
]
