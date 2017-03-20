@gradecraft.factory 'AnalyticsService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

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



