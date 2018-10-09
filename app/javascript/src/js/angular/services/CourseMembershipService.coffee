@gradecraft.factory "CourseMembershipService", ["GradeCraftAPI", "$http", (GradeCraftAPI, $http) ->

  destroy = (id) ->
    $http.delete("/course_memberships/#{id}").then(
      (response) ->
        GradeCraftAPI.logResponse(response.data)
      , (response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  toggleActivation = (id, student, notify=true) ->
    activationTerm = if student.activated_for_course is true then "deactivate" else "reactivate"

    if _confirmToggleActivation(activationTerm == "reactivate", student.name)
      $http.put("/course_memberships/#{id}/#{activationTerm}" ).then(
        (response) ->
          student.activated_for_course = response.data.active
          alert("#{student.name} was successfully #{activationTerm}d") if notify is true
          GradeCraftAPI.logResponse(response.data)
        , (response) ->
          alert("An error occurred while attempting to #{activationTerm} the student")
          GradeCraftAPI.logResponse(response.data)
      )

  # only confirm if deactivating
  _confirmToggleActivation = (reactivate, studentName) ->
    if reactivate is true then true else confirm("This will deactivate #{studentName} in your course - are you sure?")

  {
    destroy: destroy
    toggleActivation: toggleActivation
  }
]
