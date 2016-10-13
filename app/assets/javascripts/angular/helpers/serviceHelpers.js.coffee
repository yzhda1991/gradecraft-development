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

  # console logs response from $http.post(...).then((response)->...)
  logResponse = (response)->
    # formatted error response
    switch response.status
      when 200
        console.log(response.data)
      when 201
        console.log(response.statusText)
        console.log(response.data.data.attributes)
      when 400
        console.log(response.data.message)
      else
        console.log(response)


  # Format a single model from JSONAPI response.data section.
  # response is needed in options only if including from "relationships"
  dataItem = (item, response={}, options={"include":[]})->

    # attach JSON API type to attributes ("badges", "assignments", etc.)
    item.attributes.type = item.type

    # attach associated models from included list within
    _.each(options.include, (included)->
      #debugger if item.type == "assignments"
      return if !response.included || !item.relationships || !item.relationships[included]
      child =  _.find(response.included,
        {id: item.relationships[included].data.id.toString(),
        type: item.relationships[included].data.type}
      )
      item.attributes[included] = child.attributes if child
    )
    item.attributes


  # transfer models from api response data into the model array
  loadMany = (modelArray, response, options={"include":[]})->
    _.each(response.data, (item)->
      modelArray.push(dataItem(item, response, options))
    )

  # add to collection from a reponse with a single item
  addItem = (modelArray, type, response)->
    if type == response.data.type
      modelArray.push(dataItem(response.data))

  # add to collection from a reponse with an array of items
  addItems = (modelArray, type, response)->
    _.each(response.data, (item)->
      if type == item.type
        modelArray.push(dataItem(item))
    )

  deleteItem = (modelArray, item)->
    _.remove(modelArray, {id: item.id})

  # transfer models of a type from the response included section
  loadFromIncluded = (modelArray, type, response)->
    _.each(response.included, (item)->
      if item.type == type
        modelArray.push(item.attributes)
    )

  return {
    termFor: termFor
    setTermFor: setTermFor
    uriPrefix: uriPrefix
    logResponse: logResponse
    loadMany: loadMany
    addItem: addItem
    addItems: addItems
    deleteItem: deleteItem
    loadFromIncluded: loadFromIncluded
  }
)
