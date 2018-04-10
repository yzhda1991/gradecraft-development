@gradecraft.factory 'GradeReleaseService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  gradeIds = []

  postReleaseGrades = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/grades/release", grade_ids: gradeIds).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (error) ->
        GradeCraftAPI.logResponse(error)
    )

  addGradeIds = (ids...) -> gradeIds.push(ids...)

  clearGradeIds = () -> gradeIds.length = 0

  toggleGradeSelection = (gradeId) ->
    index = @gradeIds.indexOf(gradeId)
    if index > -1 then @gradeIds.splice(index, 1) else @gradeIds.push(gradeId)

  {
    gradeIds: gradeIds
    postReleaseGrades: postReleaseGrades
    addGradeIds: addGradeIds
    clearGradeIds: clearGradeIds
    toggleGradeSelection: toggleGradeSelection
  }
]
