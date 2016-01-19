@gradecraft.controller 'GradeRubricCtrl', ['$scope', 'Restangular', 'Criterion', 'CourseBadge', 'CriterionGrade','CriterionService', '$http', ($scope, Restangular, Criterion, CourseBadge, CriterionGrade, CriterionService, $http) ->

  $scope.criteria = []
  $scope.courseBadges = {}
  $scope.criterionGrades = {} # index in hash with criterion_id as key
  $scope.gsiGradeStatuses = ["In Progress", "Graded"]
  $scope.professorGradeStatuses = ["In Progress", "Graded", "Released"]
  $scope.urlId = parseInt(window.location.pathname.split('/')[2])

  $scope.pointsPossible = 0
  $scope.pointsGiven = 0

  $scope.init = (rubricId, assignmentId, studentId, criterionGrades, gradeStatus, releaseNecessary, returnURL)->
    $scope.rubricId = rubricId
    $scope.assignmentId = assignmentId
    $scope.studentId = studentId
    if gradeStatus
      $scope.gradeStatus = gradeStatus
    else
      $scope.gradeStatus = ""

    # use 'Graded' for all assignments for which release is necessary, bypass ui
    $scope.releaseNecessary = releaseNecessary
    if not $scope.releaseNecessary
      $scope.gradeStatus = "Graded"

    $scope.returnURL = returnURL

    $scope.addCriterionGrades(criterionGrades)

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
    $scope.pointsPossible - $scope.pointsGiven()

  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsGiven() > 0

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsGiven() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showCriterion = (attrs)->
    new Criterion(attrs, $scope)

  # count how many levels have been selected in the UI
  $scope.levelsSelected = []
  $scope.selectedLevels = ()->
    levels = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        levels.push criterion.selectedLevel
    )
    $scope.levelsSelected = levels
    levels


  $scope.selectedLevelIds = []
  # count how many levels have been selected in the UI
  $scope.selectedLevelIds = ()->
    levelIds = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        levelIds.push criterion.selectedLevel.id
    )
    $scope.selectedLevelIds = levelIds
    levelIds

  $scope.allCriterionIds = []
  # ids of all the criteria in the rubric
  $scope.allCriterionIds = ()->
    criterionIds = []
    angular.forEach($scope.criteria, (criterion, index)->
      criterionIds.push criterion.id
    )
    $scope.allCriterionIds = criterionIds
    criterionIds

  # count how many points have been given from those levels
  $scope.pointsGiven = ()->
    points = 0
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        points += criterion.selectedLevel.points
    )
    points

  $scope.gradedCriteria = ()->
    criteria = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        criteria.push criterion
    )
    criteria

  $scope.selectedCriteria = ()->
    criteria = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        criteria.push criterion
    )
    $scope.selectedCriteria = criteria
    criteria

  # Patch: (TODO test and then remove gradedCriteriaParams)
  # For params submitted, we want to include criteria with
  # comments but no selected level
  $scope.criteriaParams = ()->
    params = []
    angular.forEach($scope.criteria, (criterion, index)->
      # get params just from the criterion object
      criterionParams = $scope.criterionOnlyParams(criterion,index)

      # add params from the level if a level has been selected
      if criterion.selectedLevel
        jQuery.extend(criterionParams, $scope.gradedLevelParams(criterion))

      # create params for the rubric grade regardless
      params.push criterionParams
    )
    params

  $scope.gradedCriteriaParams = ()->
    params = []
    angular.forEach($scope.gradedCriteria(), (criterion, index)->
      # get params just from the criterion object
      criterionParams = $scope.criterionOnlyParams(criterion,index)

      # add params from the level if a level has been selected
      if criterion.selectedLevel
        jQuery.extend(criterionParams, $scope.gradedLevelParams(criterion))

      # create params for the rubric grade regardless
      params.push criterionParams
    )
    params

  # params for just the criterion
  $scope.criterionOnlyParams = (criterion,index)->
    {
      criterion_name: criterion.name,
      criterion_description: criterion.description,
      max_points: criterion.max_points,
      order: index,
      criterion_id: criterion.id,
      comments: criterion.comments
    }

  # additional level params if a level is selected
  $scope.gradedLevelParams = (criterion) ->
    {
      level_name: criterion.selectedLevel.name,
      level_description: criterion.selectedLevel.description,
      points: criterion.selectedLevel.points,
      level_id: criterion.selectedLevel.id
    }

  $scope.levelBadgesParams = ()->
    params = []
    # alert("# of graded criteria:" + $scope.gradedCriteria.length)
    angular.forEach($scope.gradedCriteria(), (criterion, index)->
      # alert(criterion.name)
      # grab the selected level for the active criterion
      level = criterion.selectedLevel
      angular.forEach(level.badges, (badge, index)->
        params.push {
          name: badge.name,
          level_id: level.id,
          criterion_id: level.criterion_id,
          badge_id: badge.badge.id,
          description: badge.description,
          point_total: badge.point_total,
          icon: badge.icon,
          multiple: badge.multiple
        }
      )
    )
    return params

  $scope.gradedRubricParams = ()->
    {
      points_given: $scope.pointsGiven(),
      rubric_id: $scope.rubricId,
      student_id: $scope.studentId,
      points_possible: $scope.pointsPossible,
      criterion_grades: $scope.criteriaParams(),
      level_badges: $scope.levelBadgesParams(),
      level_ids: $scope.selectedLevelIds(),
      criterion_ids: $scope.allCriterionIds(),
      grade_status: $scope.gradeStatus
    }

  $scope.submitGrade = ()->
    self = this
    if confirm "Are you sure you want to submit the grade for this assignment?"
      # alert(self.gradedRubricParams().level_badges.length)

      # !!! Document any updates to this call in the specs: /spec/support/api_calls/rubric_grade_put.rb
      $http.put("/assignments/#{$scope.assignmentId}/grade/submit_rubric", self.gradedRubricParams()).success(
        window.location = $scope.returnURL
      )
      .error(
        (data)->
          console.log(data);
      )

  $scope.addCriterionGrades = (criterionGrades)->
    angular.forEach(criterionGrades, (rg, index)->
      criterionGrade = new CriterionGrade(rg)
      $scope.criterionGrades[rg.criterion_id] = criterionGrade
    )

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadge(badge)
      $scope.courseBadges[badge.id] = courseBadge
    )

  $scope.addCriteria = (existingCriteria)->
    angular.forEach(existingCriteria, (criterion, index)->
      criterionObject = new Criterion(criterion, $scope)
      $scope.criteria.push criterionObject
      $scope.pointsPossible += criterionObject.max_points
    )

  $scope.existingCriteria = []
]
