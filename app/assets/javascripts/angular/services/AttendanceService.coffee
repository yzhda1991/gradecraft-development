@gradecraft.factory 'AttendanceService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  _saved = false
  assignments = []
  attendanceAttributes = {}

  daysOfWeek = [
    { label: "Sunday", value: "0" }
    { label: "Monday", value: "1" }
    { label: "Tuesday", value: "2" }
    { label: "Wednesday", value: "3" }
    { label: "Thursday", value: "4" }
    { label: "Friday", value: "5" }
    { label: "Saturday", value: "6" }
  ]

  getAttendanceAssignments = () ->
    $http.get('/api/attendance').then(
      (response) ->
        GradeCraftAPI.loadMany(assignments, response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  postAttendanceArticle = () ->
    saved(true)

    $http.post("/api/attendance/create_or_update", { assignments_attributes: assignments }).then(
      (response) ->
        # GradeCraftAPI.loadMany(assignments, response.data)
        GradeCraftAPI.logResponse(response)
        window.location.replace("/attendance")
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # Find all applicable dates based on the selected days of the week that are
  # between the specified start and end date and merge with the given times
  reconcileAssignments = (assignmentTypeId) ->
    dates = []
    start = angular.copy(attendanceAttributes.startDate)
    selectedDays = _.filter(daysOfWeek, 'selected')

    while start <= attendanceAttributes.endDate
      # Reconcile date with time for each date that is within the date range
      selectedDate = _.find(selectedDays, (day) ->
        start.getDay().toString() == day.value
      )
      if selectedDate?
        dates.push({
          open_at: new Date(start.getFullYear(), start.getMonth(), start.getDate(),
            selectedDate.startTime.getHours(), selectedDate.startTime.getMinutes(),
            selectedDate.startTime.getSeconds()
          )
          due_at: new Date(start.getFullYear(), start.getMonth(), start.getDate(),
            selectedDate.endTime.getHours(), selectedDate.endTime.getMinutes(),
            selectedDate.endTime.getSeconds()
          )
          assignment_type_id: assignmentTypeId
          full_points: if attendanceAttributes.has_points then attendanceAttributes.point_total else null
          pass_fail: !attendanceAttributes.has_points
        })
      start.setDate(start.getDate() + 1)

    angular.copy(dates, assignments)

  saved = (saved) ->
    if angular.isDefined(saved) then (_saved = saved) else _saved

  {
    assignments: assignments
    attendanceAttributes: attendanceAttributes
    daysOfWeek: daysOfWeek
    getAttendanceAssignments: getAttendanceAssignments
    postAttendanceArticle: postAttendanceArticle
    reconcileAssignments: reconcileAssignments
    saved: saved
  }
]
