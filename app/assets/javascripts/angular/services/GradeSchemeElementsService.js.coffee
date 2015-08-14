@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    elements = []
    deletedIds = []
    totalPoints = null

    remove = (index) ->
      deletedIds.push(elements.splice(index, 1)[0].id)

    addNew = (index) ->
      elements.splice(index+1, 0, {
        letter: ''
        level: ''
        low_range: ''
        high_range: elements[index].low_range-1
      })

    addFirst = () ->
      elements.push({
        letter: ''
        level: ''
        low_range: ''
        high_range: totalPoints
      })

    update_scheme = (index) ->
      elements[index+1].high_range = elements[index].low_range-1

    getGradeSchemeElements = ()->
      $http.get('/gse_mass_edit/').success((response) ->
        angular.copy(response.grade_scheme_elements, elements)
        totalPoints = response.total_points
      )

    postGradeSchemeElement = (id)->
      $http.put('/grade_scheme_elements/' + id).success(
        (data) ->
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    postGradeSchemeElements = ()->
      data = {
        grade_scheme_elements_attributes: elements
        deleted_ids: deletedIds
      }
      $http.put('/grade_scheme_elements/mass_edit', data).success(
        (data) ->
          angular.copy(data.grade_scheme_elements, elements)
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    return {
        getGradeSchemeElements: getGradeSchemeElements
        postGradeSchemeElement: postGradeSchemeElement
        postGradeSchemeElements: postGradeSchemeElements
        elements: elements
        remove: remove
        addFirst: addFirst
        update_scheme: update_scheme
        addNew: addNew
    }
]
