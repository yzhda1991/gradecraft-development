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
    $http.get('/api/assignments/' + assignmentId + '/criteria').success((response)->
      angular.forEach(response.data, (criterion, index)->
        criterionObject = new Criterion(criterion.attributes, _scope)
        criteria.push criterionObject
      )
    )

  addCriterionGrades = (resData)->
    angular.forEach(resData, (cg, index)->
      criterionGrade = cg.attributes
      criterionGrades[cg.attributes.criterion_id] = criterionGrade
    )

  updateCriterion = (assignmentId, recipientType, recipientId, criterion, field)->
    requestData = {}
    requestData[field] = criterion[field]
    # This doesn't handle group criterion grades, we need to add functionality
    # to update on all group criterion grades.
    if recipientType == "student"
      $http.put("/api/assignments/#{assignmentId}/students/#{recipientId}/criteria/#{criterion.id}/update_fields", criterion_grade: requestData).success(
        (data, status)->
          console.log(data)
      )
      .error((err)->
        console.log(err)
      )

  getCriterionGrades = (assignmentId, recipientType, recipientId)->
    if recipientType == "student"
      $http.get('/api/assignments/' + assignmentId + '/students/' + recipientId + '/criterion_grades/').success((response)->
        addCriterionGrades(response.data)
      )
    else if recipientType == "group"
      $http.get('/api/assignments/' + assignmentId + '/groups/' + recipientId + '/criterion_grades/').success((response)->

        # The API sends all student information so we can add the ability to custom grade group members
        # For now we filter to the first student's grade since all students grades are identical
        addCriterionGrades(_.filter(response.data, { attributes: { 'student_id': response.meta.student_ids[0] }}))
      )

  getBadges = ()->
    $http.get('/api/badges').success((response)->
      angular.forEach(response.data, (badge, index)->
        courseBadge = new CourseBadge(badge.attributes)
        badges[badge.id] = courseBadge
      )
      _badgesAvailable = true
    )

  putRubricGradeSubmission = (assignmentId, recipientType, recipientId, params, returnURL)->
    scopeRoute = if recipientType == "student" then "students" else "groups"
    $http.put("/api/assignments/#{assignmentId}/#{scopeRoute}/#{recipientId}/criterion_grades", params).success(
      (data)->
        console.log(data)
        window.location = returnURL
    ).error(
      (data)->
        console.log(data)
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
