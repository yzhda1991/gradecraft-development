@gradecraft.factory 'RubricService', ['CourseBadge', 'Criterion', 'CriterionGrade', '$http', (CourseBadge, Criterion, CriterionGrade, $http) ->

  pointsPossible = 0
  assignment = {}
  grade = {}

  gradeStatusOptions = []
  criteria = []

  #TODO standardize to array
  badges = {}
  criterionGrades = {}

  getAssignment = (location)->
    assignment.id = parseInt(location.pathname.split('/')[2])
    # GRADING A STUDENT FOR AN ASSIGNMENT
    if location.search.match(/student_id=/)
      assignment.scope = {
        type: "STUDENT",
        id: parseInt(window.location.search.match(/student_id=(\d+)/)[1])
      }
    # GRADING A GROUP FOR AN ASSIGNMENT
    else if window.location.search.match(/group_id=/)
      assignment.scope = {
        type: "GROUP",
        id: parseInt(window.location.search.match(/group_id=(\d+)/)[1])
      }
    # DESIGNING A RUBRIC
    else
      assignment.scope = {
        type: "DESIGN_MODE",
        id: null
      }

  # TODO: $scope should not be passed around if we want to avoid tight coupling
  getCriteria = (assignment, $scope)->
    _scope = $scope
    $http.get('/api/assignments/' + assignment.id + '/criteria').success((res)->
      angular.forEach(res.data, (criterion, index)->
        criterionObject = new Criterion(criterion.attributes, _scope)
        criteria.push criterionObject
      )
    )

  addCriterionGrades = (resData)->
    angular.forEach(resData, (cg, index)->
      criterionGrade = cg.attributes
      criterionGrades[cg.attributes.criterion_id] = criterionGrade
    )

  getCriterionGrades = (assignment)->
    if assignment.scope.type == "STUDENT"
      $http.get('/api/assignments/' + assignment.id + '/students/' + assignment.scope.id + '/criterion_grades/').success((res)->
        addCriterionGrades(res.data)
      )
    else if assignment.scope.type == "GROUP"
      $http.get('/api/assignments/' + assignment.id + '/groups/' + assignment.scope.id + '/criterion_grades/').success((res)->
        # We filter to the first student since all students grades are identical (for now)
        addCriterionGrades(_.filter(res.data, { attributes: { 'student_id': res.meta.student_ids[0] }}))
      )

  getBadges = ()->
    $http.get('/api/badges').success((res)->
      angular.forEach(res.data, (badge, index)->
        courseBadge = new CourseBadge(badge.attributes)
        badges[badge.id] = courseBadge
      )
    )

  getGrade = (assignment)->
    if assignment.scope.type == "STUDENT"
      $http.get('/api/assignments/' + assignment.id + '/students/' + assignment.scope.id + '/grade/').success((res)->
        angular.copy(res.data.attributes, grade)
        angular.copy(res.meta.grade_status_options, gradeStatusOptions)
      )
    else if assignment.scope.type == "GROUP"
      $http.get('/api/assignments/' + assignment.id + '/groups/' + assignment.scope.id + '/grades/').success((res)->
        # We filter to the first student's grade since all students grades are identical (for now)
        angular.copy(_.find(res.data, { attributes: {'student_id' : res.meta.student_ids[0] }}).attributes, grade)
        angular.copy(res.meta.grade_status_options, gradeStatusOptions)
      )

  putRubricGradeSubmission = (assignment, params, returnURL)->
    scopeRoute = if assignment.scope.type == "STUDENT" then "students" else "groups"
    $http.put("/api/assignments/#{assignment.id}/#{scopeRoute}/#{assignment.scope.id}/criterion_grades", params).success(
      (data)->
        console.log(data)
        window.location = returnURL
    ).error(
      (data)->
        console.log(data)
    )

  pointsPossible = ()->
    points = 0
    _.map(criteria, (criterion)->
      points += criterion.max_points
    )
    points

  return {
      getAssignment: getAssignment,
      getCriteria: getCriteria,
      getCriterionGrades: getCriterionGrades,
      getBadges: getBadges,
      getGrade: getGrade,
      putRubricGradeSubmission: putRubricGradeSubmission,
      assignment: assignment,
      badges: badges,
      criteria: criteria,
      criterionGrades: criterionGrades,
      grade: grade,
      gradeStatusOptions: gradeStatusOptions,
      pointsPossible: pointsPossible
  }
]
