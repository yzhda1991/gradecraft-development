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

  # ----------Methods for handling JSON API response data ---------------------#
  #     See http://jsonapi.org/format/ for details of data structure

  # Format a single model from JSONAPI response.data section
  # results is needed in options only if pulling other items from "relationships"
  dataItem = (item, results={}, options={"include":[]})->

    # attach JSON API type to attributes ("badges", "assignments", etc.)
    item.attributes.type = item.type

    # attach associated models from included list within
    _.each(options.include, (included)->
      return if !results.included || !item.relationships || !item.relationships[included]
      o =  _.find(results.included,
                  {id: item.relationships[included].data.id,
                  type: item.relationships[included].data.type}
          )
      item.attributes[included] = o.attributes if o
    )


  # transfer models from api results data into the model array
  loadMany = (modelArray, results, options={"include":[]})->
    _.each(results.data, (item)->
      modelArray.push(dataItem(item, results, options))
    )

  # add model from a reponse with a single item
  addOne = (modelArray, type, results)->
    if type == results.type
      modelArray.push(dataItem(results.data))

  # transfer models of a type from the json included section
  loadFromIncluded = (modelArray, type, results)->
    _.each(results.included, (item)->
      if item.type == type
        modelArray.push(item.attributes)
    )

  return {
    termFor: termFor
    setTermFor: setTermFor
    uriPrefix: uriPrefix
    loadMany: loadMany
    loadFromIncluded: loadFromIncluded
  }
)
