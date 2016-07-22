# Common Methods and Objects for Services using the GradeCraft api routes
angular.module('helpers').factory('GradeCraftAPI', ()->

  # stores custom terms, default to GC defaults
  _termFor = {
      assignmentType: "Assignment Type"
      assignment: "Assignment"
      pass: "Pass"
      fail: "Fail"
      badges: "Badges"
      challenges: "Challenges"
      weights: "Weights"
  }

  termFor = (article)->
    _termFor[article]

  setTermFor = (article,term)->
    _termFor[article] = term

  # used to destinguish student and faculty routes.
  # On init, students views do not send student id.
  uriPrefix = (studentId)->
    if studentId
      '/api/students/' + studentId + '/'
    else
      'api/'

  # transfer models from api results into the model array
  loadMany = (modelArray, res)->
    _.each(res.data, (item)->
      # attach JSON API type to attributes ("badges", "assignments", etc.)
      item.attributes.type = item.type
      modelArray.push(item.attributes)
    )

  return {
    termFor: termFor
    setTermFor: setTermFor
    uriPrefix: uriPrefix
    loadMany: loadMany
  }
)
