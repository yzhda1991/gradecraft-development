@gradecraft.factory 'GradeReleaseService', ['GradeCraftAPI', '$http', (GradeCraftAPI, $http) ->

  gradeIds = []

  postReleaseGrades = () ->
    console.log("releasing...")

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
