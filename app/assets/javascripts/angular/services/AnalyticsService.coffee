@gradecraft.factory 'AnalyticsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  assignmentData = {}


  # We should add an indication if this has already loaded, so that each plot does not
  # call the same endpoint again.

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



