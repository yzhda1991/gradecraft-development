# Currently, RubricService is used for retrieving a rubric for a rubric graded
# assignment, so the rubric id is collected from the assignment, and is read-only
# Ideally this service should be expanded to handle the rubric design process too.


@gradecraft.factory 'RubricService', ['GradeCraftAPI', 'BadgeService', '$http', (GradeCraftAPI, BadgeService, $http) ->

  rubric = {}
  criteria = []

  getRubric = (rubricId)->
    console.log("rubric: ", rubricId);
    $http.get("/api/rubrics/" + rubricId).then(
      (response) ->
        if response.data.data?  # if no rubric is found, data is null
          GradeCraftAPI.loadItem(rubric, "rubrics", response.data)
          GradeCraftAPI.loadFromIncluded(criteria, "criteria", response.data)
          GradeCraftAPI.logResponse(response.data)
      ,(response) ->
        GradeCraftAPI.logResponse(response.data)
    )

  badgesForLevel = (level)->
    return [] unless level.level_badges.length && BadgeService.badges.length
    ids = _.map(level.level_badges, (badge)->badge["badge_id"])
    # change indexBy to keyBy if lowdash is updated to v4
    badges = _(BadgeService.badges).indexBy('id').at(ids).value();

  return {
    getRubric: getRubric
    rubric: rubric
    criteria: criteria
    badgesForLevel: badgesForLevel
  }
]
