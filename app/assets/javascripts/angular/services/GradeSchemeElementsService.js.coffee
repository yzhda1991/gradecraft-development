@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    elements = []

    remove = (index) ->
      elements.splice(index, 1)

    addNew = (index) ->
      elements.splice(index+1, 0, {
        letter: ''
        level: ''
        low_range: ''
        high_range: elements[index].low_range-1
      })

    update_scheme = (index) ->
      elements[index+1].high_range = elements[index].low_range-1

    getGradeSchemeElements = ()->
      $http.get('/gse_mass_edit/').success((response) ->
        angular.copy(response.grade_scheme_elements, elements)
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
      $http.put('/grade_scheme_elements/mass_edit', grade_scheme_elements_attributes: elements).success(
        (data) ->
          angular.copy(data.grade_scheme_elements, elements)
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
        update_scheme: update_scheme
        addNew: addNew
    }
]
