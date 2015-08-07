@gradecraft.factory 'GradeSchemeElementsService', ['$http', ($http) ->
    getGradeSchemeElements = ()->
      $http.get('/gse_mass_edit/')

    postGradeSchemeElement = (id)->
      $http.put('/grade_scheme_elements/' + id).success(
        (data) ->
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    postGradeSchemeElements = (grade_scheme_elements)->
      $http.put('/grade_scheme_elements/mass_edit', grade_scheme_elements_attributes: grade_scheme_elements).success(
        (data) ->
          console.log(data)
      ).error(
        (error) ->
          console.log(error)
      )

    return {
        getGradeSchemeElements: getGradeSchemeElements
        postGradeSchemeElement: postGradeSchemeElement
        postGradeSchemeElements: postGradeSchemeElements
    }
]
