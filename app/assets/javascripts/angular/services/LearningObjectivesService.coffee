# Service for creating and updating learning objectives for the current course
@gradecraft.factory 'LearningObjectivesService', ['$http', 'GradeCraftAPI', 'DebounceQueue',
($http, GradeCraftAPI, DebounceQueue) ->

  _lastUpdated = undefined

  _levels = []
  _objectives = []
  _categories = []
  cumulativeOutcomes = []
  _observed_outcomes = []
  linkedAssignments = []
  levelFlaggedValues = []

  runAllEvents = (redirectUrl=null) ->
    DebounceQueue.runAllEvents()  # should this return a $q.all promise to ensure success prior to redirect?
    window.location.href = redirectUrl if redirectUrl?

  objective = () -> _objectives[0]

  category = () -> _categories[0]

  observedOutcomes = () -> _observed_outcomes

  cumulativeOutcomeFor = (objectiveId) ->
    _.find(cumulativeOutcomes, { learning_objective_id: objectiveId })

  cumulativeOutcomeForStudent = (objectiveId, studentId) ->
    _.find(cumulativeOutcomes, { learning_objective_id: objectiveId, user_id: studentId })

  observedOutcomesFor = (cumulativeOutcomeId, type=null, id=null) ->
    criteria = { learning_objective_cumulative_outcomes_id: cumulativeOutcomeId }
    # If filtering down to a specific assessable type (e.g. for a specific grade)
    if type? and id?
      criteria.learning_objective_assessable_type = type
      criteria.learning_objective_assessable_id = id
      _.find(_observed_outcomes, criteria)
    else
      _.filter(_observed_outcomes, criteria)

  observedOutcomesForStudent = (objectiveId, studentId) ->
    co = cumulativeOutcomeForStudent(objectiveId, studentId)
    if co? then observedOutcomesFor(co.id) else null

  earnedOutcome = (studentId, objectiveId, assignmentId) ->
    oo = observedOutcomesForStudent(objectiveId, studentId)
    if oo? then _.find(oo, { assignment_id: assignmentId }) else null

  levels = (objective) ->
    objectiveLevels = _.filter(_levels, { objective_id: objective.id })
    _.sortBy(objectiveLevels, ["order"]) if objectiveLevels?

  objectives = (category=null) ->
    if category?
      categoryId = if category == "uncategorized" then null else category.id
      _.filter(_objectives, { category_id: categoryId })
    else
      _objectives

  categories = (savedOnly=false) ->
    if savedOnly then _.filter(_categories, "id") else _categories

  addObjective = (categoryId=null) ->
    _objectives.push(
      name: undefined
      description: undefined
      countToAchieve: undefined
      category_id: categoryId
    )

  addCategory = () ->
    _categories.push(
      name: undefined
    )

  addLevel = (objectiveId) ->
    _levels.push(newLevel(objectiveId))

  newLevel = (objectiveId, order=null) ->
    {
      objective_id: objectiveId
      name: undefined
      description: undefined
      flagged_value: 1
      order: order
    }

  getOutcomesForAssignment = (assignmentId) ->
    $http.get("/api/assignments/#{assignmentId}/learning_objectives/outcomes").then(
      (response) ->
        GradeCraftAPI.loadMany(cumulativeOutcomes, response.data)
        GradeCraftAPI.loadFromIncluded(_observed_outcomes, "learning_objective_observed_outcome", response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getOutcomesForObjective = (objectiveId, studentIds...) ->
    $http.get("/api/learning_objectives/objectives/#{objectiveId}/outcomes", { params: { student_ids: studentIds } }).then(
      (response) ->
        GradeCraftAPI.loadMany(cumulativeOutcomes, response.data)
        GradeCraftAPI.loadFromIncluded(_observed_outcomes, "learning_objective_observed_outcome", response.data)
        GradeCraftAPI.setTermFor("students", response.data.meta.term_for_students)
        GradeCraftAPI.setTermFor("groups", response.data.meta.term_for_groups)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getObjective = (id) ->
    $http.get("/api/learning_objectives/objectives/#{id}").then(
      (response) ->
        GradeCraftAPI.addItem(_objectives, "learning_objective", response.data)
        GradeCraftAPI.loadFromIncluded(_levels, "levels", response.data)
        GradeCraftAPI.loadFromIncluded(linkedAssignments, "assignments", response.data)
        angular.copy(response.data.meta.level_flagged_values, levelFlaggedValues)
        GradeCraftAPI.setTermFor("learning_objective", response.data.meta.term_for_learning_objective)
        GradeCraftAPI.setTermFor("learning_objectives", response.data.meta.term_for_learning_objectives)
        GradeCraftAPI.setTermFor("assignment", response.data.meta.term_for_assignment)
        GradeCraftAPI.setTermFor("assignments", response.data.meta.term_for_assignments)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  getCategory = (id) ->
    $http.get("/api/learning_objectives/categories/#{id}").then(
      (response) ->
        GradeCraftAPI.addItem(_categories, "learning_objective_category", response.data)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # GET objectives or categories
  # Objectives are expected to come with associated levels
  getArticles = (type, options={}) ->
    $http.get("/api/learning_objectives/#{type}", { params: options }).then(
      (response) ->
        arr = if type == "objectives" then _objectives else _categories
        arr.length = 0
        GradeCraftAPI.loadMany(arr, response.data)
        if type == "objectives"
          GradeCraftAPI.loadFromIncluded(linkedAssignments, "linked_assignments", response.data)
          GradeCraftAPI.loadFromIncluded(_levels, "levels", response.data)
        else
          angular.copy(response.data.meta.level_flagged_values, levelFlaggedValues)
        GradeCraftAPI.setTermFor("learning_objective", response.data.meta.term_for_learning_objective)
        GradeCraftAPI.setTermFor("learning_objectives", response.data.meta.term_for_learning_objectives)
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
    )

  # POST/PUT articles such as learning objectives, categories
  persistArticle = (article, type, redirectUrl=null, immediate=false) ->
    return if !article.name? || article.isCreating

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type)
    else
      if immediate
        _updateArticle(article, type, null, redirectUrl)
      else
        DebounceQueue.addEvent(
          type, article.id, _updateArticle, [article, type]
        )

  # POST/PUT associated data such as learning objective levels
  # Route: /api/learning_objectives/#{association}/#{associationId}/#{type}
  # e.g. /api/learning_objectives/objectives/1/levels
  persistAssociatedArticle = (association, associationId, article, type) ->
    return if !article.name? || article.isCreating
    routePrefix = "/api/learning_objectives/#{association}/#{associationId}"

    if !isSaved(article)
      article.isCreating = true
      _createArticle(article, type, routePrefix)
    else
      DebounceQueue.addEvent(
        type, article.id, _updateArticle, [article, type, routePrefix]
      )

  # DELETE articles such as learning objectives, categories
  deleteArticle = (article, type, redirectUrl=null, message=null) ->
    arr = if type == "objectives" then _objectives else _categories
    return arr.splice(arr.indexOf(article), 1) if !article.id?
    confirmationText = "Are you sure you want to delete #{article.name}?"
    confirmationText = confirmationText.concat(message) if message?

    if confirm confirmationText
      $http.delete("/api/learning_objectives/#{type}/#{article.id}").then(
        (response) ->
          arr.splice(arr.indexOf(article), 1)
          GradeCraftAPI.logResponse(response)
          window.location.href = redirectUrl if redirectUrl?
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

  # DELETE associated articles such as learning objective levels
  deleteAssociatedArticle = (association, associationId, article, type, arr=null) ->
    arr = if arr? then arr else _levels

    if !article.id?
      arr.splice(arr.indexOf(article), 1) if !article.id?
      return

    if confirm "Are you sure you want to delete #{article.name}?"
      $http.delete("/api/learning_objectives/#{association}/#{associationId}/#{type}/#{article.id}").then(
        (response) ->
          arr.splice(arr.indexOf(article), 1)
          GradeCraftAPI.logResponse(response)
        , (response) ->
          GradeCraftAPI.logResponse(response)
      )

  updateOrder = (levels, objectiveId) ->
    $http.put("/api/learning_objectives/objectives/#{objectiveId}/levels/update_order", level_ids: _.pluck(levels, "id")).then(
      (response) ->
        _lastUpdated = new Date()
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        alert("An unexpected error occurred while saving")
        GradeCraftAPI.logResponse(response)
    )

  lastUpdated = (date) ->
    if angular.isDefined(date) then _lastUpdated = date else _lastUpdated

  termFor = (article) ->
    GradeCraftAPI.termFor(article)

  isSaved = (article) ->
    article.id?

  categoryFor = (objective) ->
    _.find(_categories, { id: objective.category_id })

  overallProgress = (objectiveId) ->
    cumulative_outcome = cumulativeOutcomeFor(objectiveId)
    return null if !cumulative_outcome?
    observedOutcomes = observedOutcomesFor(cumulative_outcome.id)
    _progress(observedOutcomes)

  statusFor = (objectiveId) ->
    co = cumulativeOutcomeFor(objectiveId)
    return "Not started" if !co?
    co.status

  _progress = (outcomes) ->
    {
      greenOutcomes: _outcomesForValue(outcomes, "green")
      yellowOutcomes: _outcomesForValue(outcomes, "yellow")
      redOutcomes: _outcomesForValue(outcomes, "red")
      totalOutcomeCount: outcomes.length
    }

  _outcomesForValue = (outcomes, value) ->
    return null if !outcomes?
    _.filter(outcomes, { flagged_value: value })

  _createArticle = (article, type, routePrefix="/api/learning_objectives") ->
    promise = $http.post("#{routePrefix}/#{type}", _params(article, type))
    _resolve(promise, article, type)

  _updateArticle = (article, type, routePrefix="/api/learning_objectives", redirectUrl=null) ->
    promise = $http.put("#{routePrefix}/#{type}/#{article.id}", _params(article, type))
    _resolve(promise, article, type, redirectUrl)

   _params = (article, type) ->
    params = {}
    term = switch type
      when "objectives" then "learning_objective"
      when "categories" then "learning_objective_category"
      when "levels" then "learning_objective_level"
    params[term] = article
    params

  _resolve = (promise, article, type, redirectUrl) ->
    promise.then(
      (response) ->
        angular.copy(response.data.data.attributes, article)
        lastUpdated(article.updated_at || new Date())
        article.isCreating = false
        window.location.href = redirectUrl if redirectUrl?
        GradeCraftAPI.logResponse(response)
      , (response) ->
        GradeCraftAPI.logResponse(response)
        alert("An unexpected error occurred while saving")
    )

  {
    runAllEvents: runAllEvents
    levels: levels
    objectives: objectives
    categories: categories
    levelFlaggedValues: levelFlaggedValues
    objective: objective
    category: category
    observedOutcomes: observedOutcomes
    cumulativeOutcomes: cumulativeOutcomes
    linkedAssignments: linkedAssignments
    cumulativeOutcomeFor: cumulativeOutcomeFor
    cumulativeOutcomeForStudent: cumulativeOutcomeForStudent
    observedOutcomesFor: observedOutcomesFor
    observedOutcomesForStudent: observedOutcomesForStudent
    earnedOutcome: earnedOutcome
    addObjective: addObjective
    addCategory: addCategory
    addLevel: addLevel
    newLevel: newLevel
    getOutcomesForAssignment: getOutcomesForAssignment
    getObjective: getObjective
    getCategory: getCategory
    getArticles: getArticles
    getOutcomesForObjective: getOutcomesForObjective
    persistArticle: persistArticle
    persistAssociatedArticle: persistAssociatedArticle
    deleteArticle: deleteArticle
    deleteAssociatedArticle: deleteAssociatedArticle
    lastUpdated: lastUpdated
    termFor: termFor
    isSaved: isSaved
    categoryFor: categoryFor
    overallProgress: overallProgress
    statusFor: statusFor
    updateOrder: updateOrder
  }
]
