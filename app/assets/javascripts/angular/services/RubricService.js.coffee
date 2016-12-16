@gradecraft.factory 'RubricService', ['CourseBadge', 'Criterion', 'CriterionGrade', '$http', 'GradeCraftAPI', 'GradeService', (CourseBadge, Criterion, CriterionGrade, $http, GradeCraftAPI, GradeService) ->

  _badgesAvailable = false

  badgesAvailable = ()->
    _badgesAvailable

  pointsPossible = 0
  thresholdPoints = 0
  assignment = {}

  # delegations to the GradeService:
  grade = GradeService.grade
  fileUploads = GradeService.fileUploads
  gradeStatusOptions =  GradeService.gradeStatusOptions

  getGrade = (assignment, recipientType, recipientId)->
    GradeService.getGrade(assignment, recipientType, recipientId)
  updateGrade = ()->
    GradeService.updateGrade()
  postAttachments = (files)->
    GradeService.postAttachments(files)
  deleteAttachment = (file)->
    GradeService.deleteAttachment(file)

  criteria = []

  # TODO standardize to array
  badges = {}
  criterionGrades = {}

  # TODO: $scope should not be passed around if we want to avoid tight coupling
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

  addCriterionGrades = (resData)->
    angular.forEach(resData, (cg, index)->
      criterionGrade = cg.attributes
      criterionGrades[cg.attributes.criterion_id] = criterionGrade
    )

  updateCriterion = (assignmentId, recipientType, recipientId, criterion, field)->
    requestData = {}
    requestData[field] = criterion[field]

    if recipientType == "student"
      $http.put("/api/assignments/#{assignmentId}/students/#{recipientId}/criteria/#{criterion.id}/update_fields", criterion_grade: requestData).then(
        (response) ->
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )
    else if recipientType == "group"
      $http.put("/api/assignments/#{assignmentId}/groups/#{recipientId}/criteria/#{criterion.id}/update_fields", criterion_grade: requestData).then(
        (response) ->
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )

  getCriterionGrades = (assignmentId, recipientType, recipientId)->
    if recipientType == "student"
      $http.get('/api/assignments/' + assignmentId + '/students/' + recipientId + '/criterion_grades/').then(
        (response) ->
          addCriterionGrades(response.data.data)
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )

    else if recipientType == "group"
      $http.get('/api/assignments/' + assignmentId + '/groups/' + recipientId + '/criterion_grades/').then(
        (response) ->
          # The API sends all student information so we can add the ability to custom grade group members
          # For now we filter to the first student's grade since all students grades are identical
          addCriterionGrades(_.filter(response.data.data, { attributes: { 'student_id': response.data.meta.student_ids[0] }}))
          GradeCraftAPI.logResponse(response)
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

  putRubricGradeSubmission = (assignmentId, recipientType, recipientId, params, returnURL)->
    scopeRoute = if recipientType == "student" then "students" else "groups"
    $http.put("/api/assignments/#{assignmentId}/#{scopeRoute}/#{recipientId}/criterion_grades", params).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
        window.location = returnURL
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  thresholdPoints = ()->
    thresholdPoints

  pointsPossible = ()->
    points = 0
    _.map(criteria, (criterion)->
      points += criterion.max_points
    )
    points

  return {
      getGrade: getGrade,
      updateGrade: updateGrade,
      grade: grade,
      fileUploads: fileUploads,
      postAttachments: postAttachments,
      deleteAttachment: deleteAttachment,
      gradeStatusOptions: gradeStatusOptions,

      badgesAvailable: badgesAvailable,
      getCriteria: getCriteria,
      getCriterionGrades: getCriterionGrades,
      getBadges: getBadges,
      putRubricGradeSubmission: putRubricGradeSubmission,
      assignment: assignment,
      badges: badges,
      criteria: criteria,
      updateCriterion: updateCriterion,
      criterionGrades: criterionGrades,
      pointsPossible: pointsPossible,
      thresholdPoints: thresholdPoints
  }
]
