@gradecraft.factory 'DashboardService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->
  dueThisWeekData = {}
  dueThisWeekAssignments = []
  plannerAssignments = []

  # API Calls
  getDueThisWeek = () ->
    $http.get('/api/dashboard/due_this_week').then(
      (response) ->
        GradeCraftAPI.loadItem(dueThisWeekData, "dueThisWeekData", response.data, { "include" : ['course_planner_assignments', 'my_planner_assignments'] })
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignments)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  termFor = (term) -> GradeCraftAPI.termFor(term)

  {
    getDueThisWeek: getDueThisWeek
    dueThisWeekData: dueThisWeekData
    dueThisWeekAssignments: dueThisWeekAssignments
    termFor: termFor
  }
]
