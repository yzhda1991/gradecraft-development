@gradecraft.factory 'GradeService', ['GradeCraftAPI', 'DebounceQueue', '$http', (GradeCraftAPI, DebounceQueue, $http) ->

  grade = {}
  fileUploads = []
  criterionGrades = []

  gradeStatusOptions = []

  isRubricGraded = false
  thresholdPoints = 0

  # used for group grades:
  grades = []
  _recipientType = ""
  _recipientId = ""

  # This must be triggered whenever there is a change to points fields or selected levels
  calculatePoints = ()->
    if isRubricGraded
      grade.raw_points = _.sum(_.map(criterionGrades, "points"))
    grade.raw_points = parseInt(grade.raw_points) || 0
    grade.adjustment_points = parseInt(grade.adjustment_points) || 0
    grade.final_points = grade.raw_points + grade.adjustment_points
    grade.final_points = 0 if grade.final_points < thresholdPoints


  _getIncluded = (response)->
    GradeCraftAPI.loadFromIncluded(fileUploads,"file_uploads", response.data)
    GradeCraftAPI.loadFromIncluded(criterionGrades,"criterion_grades", response.data)
    angular.copy(response.data.meta.grade_status_options, gradeStatusOptions)
    # bind status changes to pending_status, only update on submit
    grade.pending_status = grade.status
    thresholdPoints = response.data.meta.threshold_points
    isRubricGraded = response.data.meta.is_rubric_graded

  getGrade = (assignmentId, recipientType, recipientId)->
    _recipientType = recipientType
    _recipientId = recipientId
    if recipientType == "student"
      $http.get('/api/assignments/' + assignmentId + '/students/' + recipientId + '/grade/').then(
        (response) ->
          angular.copy(response.data.data.attributes, grade)
          _getIncluded(response)
          calculatePoints()
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )
    else if recipientType == "group"
      $http.get('/api/assignments/' + assignmentId + '/groups/' + recipientId + '/grades/').then(
        (response) ->

          # The API sends all student information so we can add the ability to custom grade group members
          # For now we filter to the first student's grade to populate the view, since all students grades are identical
          angular.copy(_.find(response.data.data, { attributes: {'student_id' : response.data.meta.student_ids[0] }}).attributes, grade)
          grade.group_id = recipientId

          _getIncluded(response)

          # We store all grades in grades, so that when updateGrade is called,
          # we can iterate through all group grades by id passing in params from grade
          GradeCraftAPI.loadMany(grades, response.data)

          # The API sends criterion grades for all group members,
          # For now we filter to those for the first student
          criterionGrades = _.filter(criterionGrades, {'grade_id': grade.id})

          calculatePoints()
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )

  _updateGradeById = (id, returnURL=null)->
    $http.put("/api/grades/#{id}", grade: grade).then(
      (response) ->
        grade.updated_at = new Date()
        GradeCraftAPI.logResponse(response)
        if returnURL
          window.location = returnURL
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  _updateGrade = (returnURL=null)->
    if _recipientType == "student"
      _updateGradeById(grade.id, returnURL)
    else if _recipientType == "group"
      _.each(grades, (g)->
        if returnURL && g == _.last(grades)
          _updateGradeById(g.id, returnURL)
        else
          _updateGradeById(g.id)
      )

  queueUpdateGrade = (immediate=false, returnURL=null) ->
    calculatePoints()
    DebounceQueue.addEvent("grades", grade.id, _updateGrade, [returnURL], immediate)


  # Final "Submit Grade" actions, includes cleanup and redirect
  submitGrade = (returnURL=null)->
    if !grade.pending_status
      return alert "You must select a grade status before you can submit this grade"

    grade.status = grade.pending_status

    return queueUpdateGrade(true, returnURL) unless isRubricGraded

    # cancel all pending updates
    DebounceQueue.cancelEvent("grades", grade.id)
    _.each(criterionGrades, (cg)->
      DebounceQueue.cancelEvent("criterion_grades", cg.criterion_id)
    )

    # parameters are configured to work with existing service
    # BuildsGrade: /services/creates_grade/builds_grade.rb
    params = {
      grade: {
        adjustment_points: grade.adjustment_points
        adjustment_points_feedback: grade.adjustment_points_feedback
        feedback: grade.feedback
        raw_points: grade.raw_points
        status: grade.status
      }
      criterion_grades: criterionGrades
    }
    $http.put("/api/assignments/#{grade.assignment_id}/#{_recipientType}s/#{_recipientId}/criterion_grades", params).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
        window.location = returnURL
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

#------- Criterion Grade Methods for Rubric Grading -------------------------------------------------------------------#

  findCriterionGrade = (criterionId)->
    return false unless isRubricGraded
    _.find(criterionGrades,{criterion_id: criterionId})

  addCriterionGrade = (criterionId, attr={})->
    return false unless isRubricGraded
    return false if findCriterionGrade(criterionId)

    criterionGrade = {
      "criterion_id": criterionId,
      "grade_id": grade.id,
      "student_id": grade.student_id,
      "level_id": null,
      "comments": null
    }
    criterionGrades.push(criterionGrade)

  setCriterionGradeLevel = (criterionId, level)->
    criterionGrade = findCriterionGrade(criterionId) || addCriterionGrade(criterionId)
    criterionGrade.level_id = level.id
    criterionGrade.points = level.points
    calculatePoints()

  _updateCriterionGrade = (criterionId)->
    criterionGrade = findCriterionGrade(criterionId)
    return false unless criterionGrade
    $http.put("/api/assignments/#{grade.assignment_id}/#{_recipientType}s/#{_recipientId}/criteria/#{criterionId}/update_fields", criterion_grade: criterionGrade).then(
      (response) ->
        GradeCraftAPI.logResponse(response)
      ,(response) ->
        GradeCraftAPI.logResponse(response)
    )

  queueUpdateCriterionGrade = (criterionId, immediate=false) ->
    # using criterionId for queue id since we are not assured to have a criterionGrade.id
    DebounceQueue.addEvent("criterion_grades", criterionId, _updateCriterionGrade, [criterionId], immediate)

#------- Grade File Methods -------------------------------------------------------------------------------------------#

  postAttachments = (files)->
    fd = new FormData();
    angular.forEach(files, (file, index)->
      fd.append("file_uploads[]", file)
    )

    $http.post(
      "/api/grades/#{grade.id}/attachments",
      fd,
      transformRequest: angular.identity,
      headers: { 'Content-Type': undefined }
    ).then(
      (response)-> # success
        if response.status == 201
          GradeCraftAPI.addItems(fileUploads, "file_uploads", response.data)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        GradeCraftAPI.logResponse(response)
    )

  deleteAttachment = (file)->
    file.deleting = true
    $http.delete("/api/grades/#{file.grade_id}/attachments/#{file.id}").then(
      (response)-> # success
        if response.status == 200
          GradeCraftAPI.deleteItem(fileUploads, file)
        GradeCraftAPI.logResponse(response)

      ,(response)-> # error
        file.deleting = false
        GradeCraftAPI.logResponse(response)
    )

  return {
    grade: grade
    fileUploads: fileUploads
    criterionGrades: criterionGrades
    gradeStatusOptions: gradeStatusOptions

    getGrade: getGrade
    queueUpdateGrade: queueUpdateGrade
    submitGrade: submitGrade

    findCriterionGrade: findCriterionGrade
    addCriterionGrade: addCriterionGrade
    setCriterionGradeLevel: setCriterionGradeLevel
    queueUpdateCriterionGrade: queueUpdateCriterionGrade

    postAttachments: postAttachments
    deleteAttachment: deleteAttachment
  }
]
