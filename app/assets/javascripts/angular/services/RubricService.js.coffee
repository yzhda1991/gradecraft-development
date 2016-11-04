@gradecraft.factory 'RubricService', ['CourseBadge', 'Criterion', 'CriterionGrade', '$http', 'GradeCraftAPI', 'GradeService', (CourseBadge, Criterion, CriterionGrade, $http, GradeCraftAPI, GradeService) ->

  _badgesAvailable = false

  badgesAvailable = ()->
    _badgesAvailable

  pointsPossible = 0
  thresholdPoints = 0
  assignment = {}

  # delegations to the GradeService:
  grade = GradeService.grade
  gradeFiles = GradeService.gradeFiles
  gradeStatusOptions =  GradeService.gradeStatusOptions
  getGrade = (assignment)->
    GradeService.getGrade(assignment)
  updateGrade = ()->
    GradeService.updateGrade()
  postGradeFiles = (files)->
    GradeService.postGradeFiles(files)
  deleteGradeFile = (file)->
    GradeService.deleteGradeFile(file)

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

  updateCriterion = (criterion, field)->
    assignment = criterion.$scope.assignment
    requestData = {}
    requestData[field] = criterion[field]
    $http.put("/api/assignments/#{assignment.id}/students/#{assignment.scope.id}/criteria/#{criterion.id}/update_fields", criterion_grade: requestData).success(
      (data, status)->
        console.log(data)
    )
    .error((err)->
      console.log(err)
    )

  getCriterionGrades = (assignment)->
    if assignment.scope.type == "student"
      $http.get('/api/assignments/' + assignment.id + '/students/' + assignment.scope.id + '/criterion_grades/').success((response)->
        addCriterionGrades(response.data)
      )
    else if assignment.scope.type == "group"
      $http.get('/api/assignments/' + assignment.id + '/groups/' + assignment.scope.id + '/criterion_grades/').success((response)->

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

  putRubricGradeSubmission = (assignment, params, returnURL)->
    scopeRoute = if assignment.scope.type == "student" then "students" else "groups"
    $http.put("/api/assignments/#{assignment.id}/#{scopeRoute}/#{assignment.scope.id}/criterion_grades", params).success(
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
      gradeFiles: gradeFiles,
      postGradeFiles: postGradeFiles,
      deleteGradeFile: deleteGradeFile,
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
