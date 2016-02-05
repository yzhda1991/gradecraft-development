@gradecraft.factory 'RubricService', ['CourseBadge', 'Criterion', '$http', (CourseBadge, Criterion, $http) ->

  pointsPossible = 0

  #TODO standardize: pick one, array or object
  badges = {}
  criteria = []

  # TODO: $scope should not be passed around if we want to avoid tight coupling
  getCriteria = (assignmentId, $scope)->
    _scope = $scope
    $http.get("/api/assignments/" + assignmentId + "/criteria").success((res)->
      angular.forEach(res.data, (criterion, index)->
        criterionObject = new Criterion(criterion.attributes, _scope)
        criteria.push criterionObject
      )
    )

  getBadges = ()->
    $http.get("/api/badges").success((res)->
      angular.forEach(res.data, (badge, index)->
        courseBadge = new CourseBadge(badge.attributes)
        badges[badge.id] = courseBadge
      )
    )

  pointsPossible = ()->
    points = 0
    _.map(criteria, (criterion)->
      points += criterion.max_points
    )
    points

  return {
      getCriteria: getCriteria,
      getBadges: getBadges,
      badges: badges,
      criteria: criteria,
      pointsPossible: pointsPossible
  }
]
