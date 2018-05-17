# Common Methods and Objects for Services using the GradeCraft api routes
angular.module('helpers').factory('GradeCraftAPI', ()->

  # stores custom terms, default to GC defaults
  _termFor = {
    assignment_type: "Assignment Type"
    assignment: "Assignment"
    pass: "Pass"
    fail: "Fail"
    badges: "Badges"
    challenges: "Challenges"
    weights: "Multipliers"
    weight: "Multiplier"
    group: "Group"
  }

  termFor = (article)->
    return if !article
    article = "assignment_type" if article.toLowerCase() == "assignmenttype" || article.toLowerCase() == "assignment type"
    _termFor[article.toLowerCase()] || article

  setTermFor = (article,term)->
    _termFor[article] = term

  # ----------Methods for handling JSON API response data ---------------------#
  #     See http://jsonapi.org/format/ for details of data structure

  # console logs response from $http.post(...).then((response)->...)
  logResponse = (response)->
    console.log(response.statusText) if response.statusText
    switch response.status
      when 200
        if response.data.message
          console.log(response.data.message)
        else
           console.log(response.data.data)
      when 201
        console.log(response.data.data)
      when 400
        console.log(response.data.errors)
      else
        console.log(response)


  # Format a single model from JSONAPI response.data section.
  # response is needed in options only if including from "relationships"
  dataItem = (item, response={}, options={"include":[]})->
    # attach JSON API type to attributes ("badges", "assignments", etc.)
    item.attributes.type = item.type

    # attach associated models from included list within
    _.each(options.include, (included)->
      return if !response.included || !item.relationships || !item.relationships[included]
      predicate = _filterPredicate(item.relationships[included].data)

      if Array.isArray(item.relationships[included].data)
        relationships = _.filter(response.included, predicate)
        item.attributes[included] = relationships if relationships?
      else
        relationship = _.find(response.included, predicate)
        item.attributes[included] = relationship.attributes if relationship?
    )
    item.attributes

  # transfer models from api response data into the model array
  loadMany = (modelArray, response, options={"include":[]})->
    _.each(response.data, (item)->
      modelArray.push(dataItem(item, response, options))
    )

  # copy to a single model from a response
  loadItem = (model, type, response, options={"include":[]}) ->
    if type == response.data.type
      angular.copy(dataItem(response.data, response, options), model)

  # add to collection from a response with a single item
  addItem = (modelArray, type, response)->
    if type == response.data.type
      modelArray.push(dataItem(response.data))

  # add to collection from a response with an array of items
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

  # need to format dates in format exepcted by datepicker
  # or it won't work
  formatDates = (article,date_fields)->
    _.each(date_fields, (field)->
      if article[field]
        article[field] = new Date(article[field]);
    )

  # constructs a filter predicate for lodash _.filter, _.find
  # based on type and id and whether the item has an object
  # or an array of relationships
  _filterPredicate = (relationships) ->
    if Array.isArray(relationships)
      id: relationships[0].id,
      type: relationships[0].type
    else
      id: relationships.id,
      type: relationships.type

  {
    termFor: termFor
    setTermFor: setTermFor
    logResponse: logResponse
    loadMany: loadMany
    loadItem: loadItem
    addItem: addItem
    addItems: addItems
    deleteItem: deleteItem
    formatDates: formatDates
    loadFromIncluded: loadFromIncluded
  }
)
