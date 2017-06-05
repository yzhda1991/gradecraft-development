# Manages state of Badges including API calls.
# Can be used independently, or via another service (see PredictorService)

@gradecraft.factory 'CourseService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  courseCreation = {}

  creationChecklist = ()->
    return [] if !courseCreation.checklist
    return courseCreation.checklist

  termFor = (article)->
    GradeCraftAPI.termFor(article)

  #------ API Calls -----------------------------------------------------------#

  getCourseCreation = ()->
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

  updateCourseCreationItem = (item)->
    params = {"course_creation" : { "#{item.name}" : item.done }}
    $http.put("/api/course_creation", params).then(
      (response)->
        GradeCraftAPI.logResponse(response)
      ,(response)->
        GradeCraftAPI.logResponse(response)
    )

  return {
    termFor,
    getCourseCreation,
    updateCourseCreationItem
    courseCreation,
    creationChecklist
  }
]
