# This legacy service relies of passing scope through factories in order to construct
# Criterion objects. It is used on the rubric design page.
# This should be replaced by the newer RubricService that
# holds a rubric state decoupled from the scope.

@gradecraft.factory 'RubricFactoryService', ['CourseBadge', 'Criterion', 'CriterionGrade', '$http', 'GradeCraftAPI', 'GradeService', (CourseBadge, Criterion, CriterionGrade, $http, GradeCraftAPI, GradeService) ->

  _badgesAvailable = false

  badgesAvailable = ()->
    _badgesAvailable

  pointsPossible = 0
  thresholdPoints = 0
  assignment = {}

  criteria = []

  # standardize to array
  badges = {}

  # $scope should not be passed around if we want to avoid tight coupling
  getCriteria = (assignmentId, $scope)->
    _scope = $scope
    $http.get('/api/assignments/' + assignmentId + '/criteria').then(
      (response) ->
        angular.forEach(response.data.data, (criterion, index)->
          # sets off factory construction chain: Criterion -> Level -> LevelBadge
          # that is dependent on badges being in scope
          criterionObject = new Criterion(criterion.attributes, _scope)
          criteria.push criterionObject
        )
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  getBadges = ()->
    $http.get('/api/badges').then(
      (response) ->
        angular.forEach(response.data.data, (badge, index)->
          courseBadge = new CourseBadge(badge.attributes)
          badges[badge.id] = courseBadge
        )
        _badgesAvailable = true
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  pointsPossible = ()->
    points = 0
    _.map(criteria, (criterion)->
      points += criterion.max_points
    )
    points

  return {
      badgesAvailable: badgesAvailable
      getCriteria: getCriteria
      getBadges: getBadges
      assignment: assignment
      badges: badges
      criteria: criteria
      pointsPossible: pointsPossible
  }
]
