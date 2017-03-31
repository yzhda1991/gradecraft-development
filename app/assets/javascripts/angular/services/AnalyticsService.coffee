@gradecraft.factory 'AnalyticsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  # We could add an indication if this has already loaded, or is loading,
  # to limit it to one call to the API, and put the directives in waiting pattern.
  # For simplicity sake, each graph on the analytics page initiating the api call.
  assignmentData = {}

  getAssignmentAnalytics = (assignmentId, studentId)->
    $http.get("/api/assignments/#{assignmentId}/analytics?student_id=#{studentId}").then(
      (response) ->
        angular.copy(response.data, assignmentData)
        GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  return {
      getAssignmentAnalytics: getAssignmentAnalytics
      assignmentData: assignmentData
  }
]
