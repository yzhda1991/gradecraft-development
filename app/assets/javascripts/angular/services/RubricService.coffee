# Currently, RubricService is used for retrieving a rubric for a rubric graded
# assignment, so the rubric id is collected from the assignment, and is read-only
# Ideally this service should be expanded to handle the rubric design process too.


@gradecraft.factory 'RubricService', ['GradeCraftAPI', 'BadgeService', '$http', (GradeCraftAPI, BadgeService, $http) ->

  rubric = {}
  criteria = []
  full_points = 0

  _editingBadgesId = null

  getRubric = (rubricId)->
    $http.get("/api/rubrics/" + rubricId).then(
      (response) ->
        if response.data.data?  # if no rubric is found, data is null
          GradeCraftAPI.loadItem(rubric, "rubrics", response.data)
          GradeCraftAPI.loadFromIncluded(criteria, "criteria", response.data)
          full_points = response.data.meta.full_points
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  addLevelBadge = (level, badgeId)->
    $http.post("/api/level_badges", {level_id: level.id, badge_id: badgeId}).then(
      (response)-> # success
        if response.status == 201
          updatedCriteria = _.map(criteria, (criterion)->
            if( _.find(criterion.levels, level))
              _.map(criterion.levels, (currentLevel)->
                if(currentLevel.id == level.id)
                  currentLevel.level_badges.push(response.data.data.attributes)
            )
            return criterion
          )
          angular.copy(updatedCriteria, criteria)
        GradeCraftAPI.logResponse(response)
      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )


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
    addLevelBadge: addLevelBadge

    rubric: rubric
    criteria: criteria
    full_points: full_points
    badgesForLevel: badgesForLevel

    editBadgesForLevel: editBadgesForLevel
    editingBadgesForLevel: editingBadgesForLevel
    closeBadgesForLevel: closeBadgesForLevel

    meetsExpectationsSet: meetsExpectationsSet
    isMeetsExpectationsLevel: isMeetsExpectationsLevel
    satifiesExpectations: satifiesExpectations
  }
]
