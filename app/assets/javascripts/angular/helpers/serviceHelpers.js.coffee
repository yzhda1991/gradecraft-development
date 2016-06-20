# Common Methods and Objects for Services using the GradeCraft api routes
angular.module('helpers')
  .factory('GradeCraftAPI', ()->

    # stores update state across services
    # json meta includes calls to update ex. 'update_assignments' = true
    # This is checked before sending PUT and POST requests.
    # Use case: faculty using Predictor shouldn't send any updates
    # example use (from PredictorService):
    #   update.assignments = res.meta.update_assignments
    update = {}

    # stores custom terms, default to GC defaults
    termFor = {
        assignmentType: "Assignment Type"
        assignment: "Assignment"
        pass: "Pass"
        fail: "Fail"
        badges: "Badges"
        challenges: "Challenges"
        weights: "Weights"
    }

    # used to destinguish student and faculty routes.
    # On init, students views do not send student id.
    uri_prefix = (studentId)->
      if studentId
        '/api/students/' + studentId + '/'
      else
        'api/'

    return {
      update: update,
      termFor: termFor,
      uri_prefix: uri_prefix
    }
  )
