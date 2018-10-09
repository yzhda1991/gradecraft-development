@gradecraft.factory 'DashboardService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->
  dueThisWeekData = {}
  dueThisWeekAssignments = []
  plannerAssignments = []

  # API Calls
  getDueThisWeek = () ->
    $http.get('/api/dashboard/due_this_week').then(
      (response) ->
        GradeCraftAPI.loadItem(dueThisWeekData, "dueThisWeekData", response.data)
        GradeCraftAPI.loadFromIncluded(dueThisWeekAssignments, "course_planner_assignments", response.data)
        GradeCraftAPI.loadFromIncluded(plannerAssignments, "my_planner_assignments", response.data)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignments)
        GradeCraftAPI.setTermFor("predictor", response.data.meta.term_for_predictor)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  termFor = (term) -> GradeCraftAPI.termFor(term)

  {
    getDueThisWeek: getDueThisWeek
    dueThisWeekData: dueThisWeekData
    dueThisWeekAssignments: dueThisWeekAssignments
    plannerAssignments: plannerAssignments
    termFor: termFor
  }
]
