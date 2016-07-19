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

    update_scheme = (index, newValue) ->
      if (index != elements.length - 1)
        elements[index + 1].highest_points = newValue - 1

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
