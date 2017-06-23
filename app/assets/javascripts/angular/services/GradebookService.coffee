@gradecraft.factory 'GradebookService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  students = []

  # Get assignment names sorted by assignment type order, assignment order
  getOrderedAssignments = ()->
    $http.get("/api/course_creation").then(
      (response)->
        GradeCraftAPI.loadItem(courseCreation, "course_creation", response.data)
        GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignments)
        GradeCraftAPI.setTermFor("badges", response.data.meta.term_for_badges)
        GradeCraftAPI.setTermFor("teams", response.data.meta.term_for_teams)
        GradeCraftAPI.logResponse(response)
      ,(response)->
        GradeCraftAPI.logResponse(response)
    )

  {
    students: students
  }
]
