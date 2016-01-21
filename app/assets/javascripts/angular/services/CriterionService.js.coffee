@gradecraft.factory 'CriterionService', ['$http', ($http) ->
    getCriteria = (assignmentId)->
      $http.get("/assignments/" + assignmentId + "/rubric/existing_criteria.json")

    getBadges = (assignmentId)->
      $http.get("/assignments/" + assignmentId + "/rubric/course_badges.json")

    return {
        getCriteria: getCriteria,
        getBadges: getBadges
    }
]
