@gradecraft.factory 'GradeService', ['GradeCraftAPI', '$http', '$timeout', (GradeCraftAPI, $http, $timeout) ->

  grade = {}
  fileUploads = []
  gradeStatusOptions = []
  autoSaveTimeInterval = 3000
  updateTimeout = null

  # used for group grades:
  grades = []
  _recipientType = ""

  getGrade = (assignmentId, recipientType, recipientId)->
    _recipientType = recipientType
    if recipientType == "student"
      $http.get('/api/assignments/' + assignmentId + '/students/' + recipientId + '/grade/').then(
        (response) ->
          angular.copy(response.data.data.attributes, grade)
          GradeCraftAPI.loadFromIncluded(fileUploads,"file_uploads", response.data)
          angular.copy(response.data.meta.grade_status_options, gradeStatusOptions)
          thresholdPoints = response.data.meta.threshold_points
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )
    else if recipientType == "group"
      $http.get('/api/assignments/' + assignmentId + '/groups/' + recipientId + '/grades/').then(
        (response) ->

          # The API sends all student information so we can add the ability to custom grade group members
          # For now we filter to the first student's grade to populate the view, since all students grades are identical
          # We store all grades in grades, so that when updateGrade is called, we can iterate through all group grades
          angular.copy(_.find(response.data.data, { attributes: {'student_id' : response.data.meta.student_ids[0] }}).attributes, grade)
          GradeCraftAPI.loadMany(grades, response.data)

          angular.copy(response.data.meta.grade_status_options, gradeStatusOptions)
          thresholdPoints = response.data.meta.threshold_points
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )

  toggleCustomValue = ()->
    grade.is_custom_value = !grade.is_custom_value

  enableCustomValue = ()->
    this.toggleCustomValue() if grade.is_custom_value == false

  enableScoreLevels = (event)->
    this.toggleCustomValue() if grade.is_custom_value == true

  justUpdated = ()->
    this.timeSinceUpdate() < 1000

  timeSinceUpdate = ()->
    Math.abs(new Date() - grade.updated_at)

  _updateGradeById = (id)->
      $http.put("/api/grades/#{id}", grade: grade).then(
        (response) ->
          grade.updated_at = new Date()
          GradeCraftAPI.logResponse(response)
        ,(response) ->
          GradeCraftAPI.logResponse(response)
      )

  updateGrade = ()->
    if _recipientType == "student"
      _updateGradeById(grade.id)
    else if _recipientType == "group"
      _.each(grades, (g)->
        _updateGradeById(g.id)
      )

  queueUpdateGrade = (immediate = false) ->
    if immediate is true
      $timeout.cancel(self.updateTimeout)
      updateGrade()
    else
      $timeout.cancel(self.updateTimeout) if self.updateTimeout?
      self.updateTimeout = $timeout(() ->
        updateGrade()
      , 3500)

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
    grade: grade,
    fileUploads: fileUploads,
    gradeStatusOptions: gradeStatusOptions,

    toggleCustomValue: toggleCustomValue,
    enableCustomValue: enableCustomValue,
    enableScoreLevels: enableScoreLevels,
    justUpdated: justUpdated,
    timeSinceUpdate: timeSinceUpdate,

    getGrade: getGrade,
    queueUpdateGrade: queueUpdateGrade,
    updateGrade: updateGrade,
    postAttachments: postAttachments,
    deleteAttachment: deleteAttachment
  }
]
