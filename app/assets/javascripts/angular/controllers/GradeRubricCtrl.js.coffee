@gradecraft.controller 'GradeRubricCtrl', ['$scope','Restangular', 'RubricService', '$q', ($scope, Restangular, RubricService, $q) ->

  $scope.courseBadges = RubricFactoryService.badges
  $scope.criteria = RubricFactoryService.criteria
  $scope.criterionGrades = RubricFactoryService.criterionGrades
  $scope.grade = RubricFactoryService.grade
  $scope.updateGrade = RubricFactoryService.updateGrade
  $scope.gradeStatusOptions = RubricFactoryService.gradeStatusOptions

  $scope.init = (assignmentId, recipientType, recipientId)->
    $scope.assignmentId = assignmentId
    $scope.recipientType = recipientType
    $scope.recipientId = recipientId

    # Criterion factory is dependent on CriterionGrades already existing in scope
    $scope.services()

  $scope.services = () ->
    # because getting Criteria requires badges from $scope
    # we need to wait until the badges are created before
    # making this call.
    queCriteriaAfterBadges = ()->
      if (RubricFactoryService.badgesAvailable() == false)
        window.setTimeout(queCriteriaAfterBadges, 100)
      else
        RubricFactoryService.getCriteria($scope.assignmentId, $scope)

    promises = [
      RubricFactoryService.getBadges(),
      RubricFactoryService.getCriterionGrades($scope.assignmentId, $scope.recipientType, $scope.recipientId),
      queCriteriaAfterBadges(),
      RubricFactoryService.getGrade($scope.assignmentId, $scope.recipientType, $scope.recipientId)]
    $q.all(promises)

  $scope.updateCriterion = (criterion, field)->
    RubricFactoryService.updateCriterion($scope.assignmentId, $scope.recipientType, $scope.recipientId, criterion, field)

  $scope.pointsPossible = ()->
    RubricFactoryService.pointsPossible()

  $scope.thresholdPoints = ()->
    RubricFactoryService.thresholdPoints()

  # distill key/value pairs for criterion ids and relative order
  $scope.pointsAssigned = ()->
    points = 0
    angular.forEach($scope.criteria, (criterion, index)->
      points += criterion.max_points if criterion.max_points
    )
    points or 0

  $scope.adjustmentPoints = ()->
    parseInt($scope.grade.adjustment_points) || 0

  $scope.pointsAdjusted = ()->
    $scope.adjustmentPoints() != 0

  # sum of points from selected levels
  $scope.pointsAllocated = ()->
    points = 0
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        points += criterion.selectedLevel.points
    )
    points

  $scope.finalPoints = ()->
    finalPoints = $scope.pointsAllocated() + $scope.adjustmentPoints()
    if $scope.isBelowThreshold() then 0 else finalPoints

  $scope.isBelowThreshold = ()->
    $scope.thresholdPoints() > $scope.pointsAllocated() + $scope.adjustmentPoints()

  $scope.pointsBelowThreshold = ()->
    $scope.thresholdPoints() - $scope.pointsAllocated() - $scope.adjustmentPoints()

  $scope.pointsDifference = ()->
    $scope.pointsPossible() - $scope.pointsAllocated()

  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsAllocated() > 0

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsAllocated() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  # count how many levels have been selected in the UI
  $scope.selectedLevels = ()->
    levels = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        levels.push criterion.selectedLevel
    )
    levels

  # count how many levels have been selected in the UI
  $scope.selectedLevelIds = ()->
    levelIds = []
    angular.forEach($scope.criteria, (criterion, index)->
      if criterion.selectedLevel
        levelIds.push criterion.selectedLevel.id
    )
    levelIds

  # ids of all the criteria in the rubric
  $scope.allCriterionIds = ()->
    criterionIds = []
    angular.forEach($scope.criteria, (criterion, index)->
      criterionIds.push criterion.id
    )
    criterionIds

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
      criterion_name:        criterion.name,
      criterion_description: criterion.description,
      max_points:            criterion.max_points,
      order:                 index,
      criterion_id:          criterion.id,
      comments:              criterion.comments
    }

  # additional level params if a level is selected
  $scope.gradedLevelParams = (criterion) ->
    {
      level_name:        criterion.selectedLevel.name,
      level_description: criterion.selectedLevel.description,
      points:            criterion.selectedLevel.points,
      level_id:          criterion.selectedLevel.id
    }

  $scope.gradeParams = ()->
    {
      raw_points: $scope.pointsAllocated(),
      feedback: $scope.grade.feedback,
      status:   $scope.grade.status,
      adjustment_points: $scope.grade.adjustment_points || 0,
      adjustment_points_feedback: $scope.grade.adjustment_points_feedback
    }

  # Document any updates to this format in the specs: /spec/support/api_calls/rubric_grade_put.rb
  # student_id or group_id is now passed through the route, see RubricFactoryService.putRubricGradeSubmission
  $scope.gradedRubricParams = ()->
    {
      points_possible:  $scope.pointsPossible(),
      criterion_grades: $scope.criteriaParams(),
      level_ids:        $scope.selectedLevelIds(),
      criterion_ids:    $scope.allCriterionIds(),
      grade:            $scope.gradeParams(),
    }

  confirmMessage = ()->
    message = "Are you sure you want to submit the grade for this assignment?"
    if _.every($scope.criteria, "selectedLevel")
      message
    else
      message + " You still have criteria without a selected level."

  $scope.submitGrade = (returnURL)->
    if !$scope.grade.status
      return alert "You must select a grade status before you can submit this grade"
    if confirm confirmMessage()
      RubricFactoryService.putRubricGradeSubmission($scope.assignmentId, $scope.recipientType, $scope.recipientId, $scope.gradedRubricParams(), returnURL)

  $scope.froalaOptions = {
    heightMin: 120,
    toolbarButtons: [
      'bold', 'italic', 'underline', 'strikeThrough',
      'sep', 'formatBlock', 'insertOrderedList', 'insertUnorderedList',
      'insertHorizontalRule', 'insertLink'
    ]
  }
]
