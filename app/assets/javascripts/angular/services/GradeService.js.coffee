@gradecraft.factory 'GradeService', ['$http', 'GradeCraftAPI', ($http, GradeCraftAPI) ->

  grade = {}
  fileUploads = []
  gradeStatusOptions = []

  getGrade = (assignmentId, recipientType, recipientId)->
    if recipientType == "student"
      $http.get('/api/assignments/' + assignmentId + '/students/' + recipientId + '/grade/').success((response)->
        angular.copy(response.data.attributes, grade)
        GradeCraftAPI.loadFromIncluded(fileUploads,"file_uploads", response)
        angular.copy(response.meta.grade_status_options, gradeStatusOptions)
        thresholdPoints = response.meta.threshold_points
      )
    else if recipientType == "group"
      $http.get('/api/assignments/' + assignmentId + '/groups/' + recipientId + '/grades/').success((response)->

        # The API sends all student information so we can add the ability to custom grade group members
        # For now we filter to the first student's grade since all students grades are identical
        angular.copy(_.find(response.data, { attributes: {'student_id' : response.meta.student_ids[0] }}).attributes, grade)
        angular.copy(response.meta.grade_status_options, gradeStatusOptions)
        thresholdPoints = response.meta.threshold_points
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

  updateGrade = ()->
    $http.put("/api/grades/#{grade.id}", grade: grade).success(
      (data,status)->
        console.log(data)
        grade.updated_at = new Date()
    )
    .error((err)->
      console.log(err)
    )

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
    updateGrade: updateGrade,
    postAttachments: postAttachments,
    deleteAttachment: deleteAttachment
  }
]
