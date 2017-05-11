# Currently, RubricService is used for retrieving a rubric for a rubric graded
# assignment, so the rubric id is collected from the assignment, and is read-only
# Ideally this service should be expanded to handle the rubric design process too.


@gradecraft.factory 'RubricService', ['BadgeService', 'GradeCraftAPI', 'DebounceQueue', '$http', (BadgeService, GradeCraftAPI, DebounceQueue, $http) ->

  rubric = {}
  criteria = []
  levels = []
  newLevels = []
  full_points = 0

  _editingBadgesId = null

  getRubric = (rubricId)->
    $http.get("/api/rubrics/" + rubricId).then(
      (response) ->
        if response.data.data?  # if no rubric is found, data is null
          GradeCraftAPI.loadItem(rubric, "rubrics", response.data)
          GradeCraftAPI.loadFromIncluded(criteria, "criteria", response.data)
          GradeCraftAPI.loadFromIncluded(levels, "levels", response.data)
          full_points = response.data.meta.full_points
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  criterionLevels = (criterion)->
    _.filter(levels, {criterion_id: criterion.id})

  deleteLevel = (level)->
    if confirm("Are you sure you want to delete this level?")
      $http.delete("/api/levels/#{level.id}").then(
        (response)-> # success
          angular.copy(_.reject(levels, {id: level.id}), levels)
          GradeCraftAPI.logResponse(response)
        ,(response)-> # error
          GradeCraftAPI.logResponse(response)
      )

#----------- NEW LEVELS -------------------------------------------------------#

# New Levels are not saved until they are valid
# Until then they exist in the newLevels array

# Assumes only one new level per criterion

  addNewLevel = (criterion)->
    newLevels.push({
      criterion_id: criterion.id,
      name: "",
      points: null
      description: ""
    })

  levelIsValid = (level)->
    return false if !level.name || level.name.length < 1
    return false if level.points == null
    return true

  # Refresh the array of new levels with a successfull response from the API
  _refreshNewLevel = (newLevel, data)->
    updatedLevels = _.map(newLevels, (level)->
      if(level.criterion_id == newLevel.criterion_id)
        level = data
      return level
    )
    angular.copy(updatedLevels, newLevels)


  # When valid, the new level is created, but not added to the
  # criterion levels array until blur, to avoid shuffling the
  # levels by points while the user is in the middle of editing
  _saveNewLevel = (newLevel)->
    $http.post("/api/levels", newLevel).then(
      (response)-> # success
        _refreshNewLevel(newLevel,response.data.data.attributes)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  _updateNewLevel = (newLevel)->
    $http.post("/api/levels/#{newLevel.id}").then(
      (response)-> # success
        _refreshNewLevel(newLevel,response.data.data.attributes)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  queueUpdateNewLevel = (newLevel)->
    return if newLevel.is_saving
    return if !levelIsValid(newLevel)
    if newLevel.id == undefined
      newLevel.is_saving = true
      _saveNewLevel(newLevel)
    else
      DebounceQueue.addEvent(
        "levels", newLevel.criterion_id, _updateNewLevel, [newLevel]
      )


  removeNewLevel = (newLevel)->
    updatedNewLevels = _.reject(newLevels, {criterion_id: newLevel.criterion_id})
    angular.copy(updatedNewLevels, newLevels)

#----------- LEVELS BADGES -------------------------------------------------------#

  addLevelBadge = (level, badgeId)->
    $http.post("/api/level_badges", {level_id: level.id, badge_id: badgeId}).then(
      (response)-> # success
        if response.status == 201
          updatedLevels = _.map(levels, (currentLevel)->
            if currentLevel.id == level.id
              currentLevel.level_badges.push(response.data.data.attributes)
              currentLevel.available_badges = _.reject(currentLevel.available_badges,(id: response.data.data.attributes.badge_id))
            return currentLevel
          )
          angular.copy(updatedLevels, levels)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  deleteLevelBadge = (level, badgeId)->
    levelBadge = _.find(level.level_badges, {badge_id: badgeId})
    if levelBadge
      $http.delete("/api/level_badges/#{levelBadge.id}").then(
        (response)-> # success
          if response.status == 200
            updatedLevels = _.map(levels, (currentLevel)->
              if currentLevel.id == level.id
                currentLevel.level_badges = _.reject(currentLevel.level_badges,(badge_id: badgeId))
                badge = _.find(BadgeService.badges, {id: badgeId})
                currentLevel.available_badges.push({id: badge.id, name: badge.name})
              return currentLevel
            )
            angular.copy(updatedLevels, levels)
          GradeCraftAPI.logResponse(response)
        ,(response)-> # error
          GradeCraftAPI.logResponse(response)
      )
    else
      console.log("error: level badge not found");

  badgesForLevel = (level)->
    return [] unless level.level_badges.length && BadgeService.badges.length
    ids = _.map(level.level_badges, (badge)->badge["badge_id"])
    # change indexBy to keyBy if lowdash is updated to v4
    badges = _(BadgeService.badges).indexBy('id').at(ids).value();

  # We only allow one open modal for editing badges
  editBadgesForLevel = (level)->
     _editingBadgesId = level.id

  editingBadgesForLevel = (level)->
    level.id == _editingBadgesId

  closeBadgesForLevel = ()->
    _editingBadgesId = null

  _refreshExpectations = (level,data)->
    updatedCriteria = _.map(criteria, (criterion)->
      if(criterion.id == level.criterion_id)
        criterion = data.data.attributes
      return criterion
    )
    angular.copy(updatedCriteria, criteria)
    updatedLevels = _.reject(levels, {criterion_id: level.criterion_id})
    GradeCraftAPI.loadFromIncluded(updatedLevels, "levels", data)
    angular.copy(updatedLevels, levels)


  setMeetsExpectations = (level)->
    $http.put("/api/criteria/#{level.criterion_id}/levels/#{level.id}/set_expectations").then(
      (response)-> # success
        if response.status == 200
          _refreshExpectations(level, response.data)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  removeMeetsExpectations = (level)->
    $http.put("/api/criteria/#{level.criterion_id}/remove_expectations").then(
      (response)-> # success
        if response.status == 200
          _refreshExpectations(level, response.data)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  updateMeetsExpectationsLevel = (criterion, level)->
    if isMeetsExpectationsLevel(criterion, level)
      removeMeetsExpectations(level)
    else
      setMeetsExpectations(level)

  # This criterion has a level set as "meets expectations"
  meetsExpectationsSet = (criterion)->
    criterion.meets_expectations_points > 0

  # This is the level that is set for "meets expectations"
  isMeetsExpectationsLevel = (criterion, level)->
    criterion.meets_expectations_level_id == level.id

  # This level is or exceeds the "meets expectations" level
  satifiesExpectations = (criterion, level)->
    meetsExpectationsSet(criterion) && (level.points >= criterion.meets_expectations_points)


  return {
    getRubric: getRubric
    criterionLevels: criterionLevels

    deleteLevel: deleteLevel

    newLevels: newLevels
    addNewLevel: addNewLevel
    removeNewLevel: removeNewLevel
    queueUpdateNewLevel: queueUpdateNewLevel

    addLevelBadge: addLevelBadge
    deleteLevelBadge: deleteLevelBadge

    rubric: rubric
    criteria: criteria
    full_points: full_points
    badgesForLevel: badgesForLevel

    editBadgesForLevel: editBadgesForLevel
    editingBadgesForLevel: editingBadgesForLevel
    closeBadgesForLevel: closeBadgesForLevel

    updateMeetsExpectationsLevel: updateMeetsExpectationsLevel
    meetsExpectationsSet: meetsExpectationsSet
    isMeetsExpectationsLevel: isMeetsExpectationsLevel
    satifiesExpectations: satifiesExpectations
  }
]
