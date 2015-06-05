@gradecraft.factory 'MetricsServices', ['$http', ($http) ->

    getMetrics = (assignmentId)->
      $http.get("/assignments/" + assignmentId + "/rubric/existing_metrics.json")
    return {
      getMetrics: getMetrics
    }
]
