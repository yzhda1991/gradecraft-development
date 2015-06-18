@gradecraft.factory 'PredictorService', ['$http', ($http) ->
    getMetrics = (assignmentId)->
      $http.get("/assignments/" + assignmentId + "/rubric/existing_metrics.json")

    getBadges = (assignmentId)->
      $http.get("/assignments/" + assignmentId + "/rubric/course_badges.json")

    return {
        getMetrics: getMetrics,
        getBadges: getBadges
    }
]
