@gradecraft.factory "GradeReleaseService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  gradeIds = []

  # If grade ids are for assorted assignment ids in the course
  postRelease = () ->
    $http.put("/api/assignments/grades/release", grade_ids: gradeIds).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (error) ->
        GradeCraftAPI.logResponse(error)
    )

  # If the grade ids all belong to a specific assignment in the course
  postReleaseForAssignment = (assignmentId) ->
    $http.put("/api/assignments/#{assignmentId}/grades/release", grade_ids: gradeIds).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      , (error) ->
        GradeCraftAPI.logResponse(error)
    )

  addGradeIds = (ids...) -> gradeIds.push(ids...)

  clearGradeIds = (ids...) -> if ids.length > 0 then _.pull(gradeIds, ids...) else gradeIds.length = 0

  hasSelectedGrades = () -> _.some(gradeIds)

  toggleGradeSelection = (gradeId) ->
    index = @gradeIds.indexOf(gradeId)
    if index > -1 then @gradeIds.splice(index, 1) else @gradeIds.push(gradeId)

  {
    gradeIds: gradeIds
    postRelease: postRelease
    postReleaseForAssignment: postReleaseForAssignment
    addGradeIds: addGradeIds
    clearGradeIds: clearGradeIds
    hasSelectedGrades: hasSelectedGrades
    toggleGradeSelection: toggleGradeSelection
  }
]
