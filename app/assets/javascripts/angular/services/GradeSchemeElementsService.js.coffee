@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    elements = []
    deletedIds = []

    # we're doing so much index juggling here that we should really create a
    # factory for both the overall grade scheme elements collection, as well as
    # for the individual grade scheme elements so we don't have to do all of
    # this work inside of the service object.

    remove = (index) ->
      deletedIds.push(elements.splice(index, 1)[0].id)

    addNew = (index) ->
      newElement = newElementAtIndex(index + 1)
      elements.splice(index + 1, 0, newElement)

    addFirst = () ->
      elements.push({
        letter: ''
        level: ''
        lowest_points: ''
        highest_points: ''
      })

    # build a new element for the given index, taking its values from the
    # elements surrounding it
    newElementAtIndex = (index) ->
      {
        letter: ''
        level: ''
        highest_points: highestPoints(index)
        lowest_points: lowestPoints(index)
      }

    highestPoints = (index) ->
      prevElement = elements[index - 1]
      if prevElement && prevElement.lowest_points > 0
        prevElement.lowest_points - 1
      else
        0

    lowestPoints = (index) ->
      nextElement = elements[index]
      if nextElement && nextElement.highest_points > 0
        nextElement.highest_points + 1
      else
        0

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
        elements: elements
        remove: remove
        addNew: addNew
        addFirst: addFirst
    }

]
