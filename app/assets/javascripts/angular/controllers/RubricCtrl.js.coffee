@gradecraft.controller 'RubricCtrl', ['$scope', 'Restangular', 'Criterion', 'CourseBadge', 'CriterionService', '$http', ($scope, Restangular, Criterion, CourseBadge, CriterionService, $http) ->
  Restangular.setRequestSuffix('.json')
  $scope.criteria = []
  $scope.courseBadges = {}
  $scope.savedCriterionCount = 0
  $scope.urlId = parseInt(window.location.pathname.split('/')[2])

  $scope.init = (rubricId, pointTotal)->
    $scope.rubricId = rubricId
    $scope.pointTotal = parseInt(pointTotal)

  CriterionService.getBadges($scope.urlId).success (courseBadges)->
    $scope.addCourseBadges(courseBadges)
  CriterionService.getCriteria($scope.urlId).success (criteria)->
    $scope.addCriteria(criteria)

  # distill key/value pairs for criterion ids and relative order
  $scope.pointsAssigned = ()->
    points = 0
    angular.forEach($scope.criteria, (criterion, index)->
      points += criterion.max_points if criterion.max_points
    )
    points or 0

  $scope.pointsDifference = ()->
    $scope.pointTotal - $scope.pointsAssigned()

  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsAssigned() > 0

  # check whether points overview is hidden
  # $scope.pointsOverviewHidden = ()->
  #  element = angular.element(document.querySelector('#points-overview'))
  #  element.is('visible')

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsAssigned() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showCriterion = (attrs)->
    new Criterion(attrs, $scope)

  $scope.countSavedCriterion = () ->
    $scope.savedCriterionCount += 1

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadge(badge)
      $scope.courseBadges[badge.id] = courseBadge
    )

  $scope.addCriteria = (existingCriteria)->
    angular.forEach(existingCriteria, (em, index)->
      emProto = new Criterion(em, $scope)
      $scope.countSavedCriterion() # indicate saved criterion present
      $scope.criteria.push emProto
    )

  $scope.newCriterion = ()->
    m = new Criterion(null, $scope)
    $scope.criteria.push m

  $scope.getNewCriterion = ()->
    $scope.newerCriterion = Restangular.one('criteria', 'new.json').getList().then ()->

  $scope.viewCriteria = ()->
    if $scope.criteria.length > 0
      $scope.displayCriteria = []
      angular.forEach($scope.criteria, (value, key)->
        $scope.displayCriteria.push(value.name)
      )
      $scope.displayCriteria

  $scope.existingCriteria = []

  # declare a sortableEle variable for the sortable function
  sortableEle = undefined

  # action when a sortable drag begins
  $scope.dragStart = (e, ui) ->
    ui.item.data "start", ui.item.index()
    return

  # action when a sortable drag completes
  $scope.dragEnd = (e, ui) ->
    start = ui.item.data("start")
    end = ui.item.index()
    $scope.criteria.splice end, 0, $scope.criteria.splice(start, 1)[0]
    $scope.$apply()
    $scope.updateCriterionOrder()
    return

  # send the criterion order to the server with ids
  $scope.updateCriterionOrder = ()->
    if $scope.savedCriterionCount > 0
      $http.put("/criteria/update_order", criterion_order: $scope.orderedCriteria()).success(
      )
      .error(
      )

  # distill key/value pairs for criterion ids and relative order
  $scope.orderedCriteria = ()->
    criteria = {}
    angular.forEach($scope.criteria, (value, index)->
      criteria[value.id] = {order: index} if value.id != null
    )
    criteria

  sortableEle = $("#criterion-box").sortable(
    start: $scope.dragStart
    update: $scope.dragEnd
  )
  return
]
