@gradecraft.controller 'GradeCtrl', ['$scope', 'AssignmentService', 'GradeService', ($scope, AssignmentService, GradeService) ->

  $scope.grade = GradeService.grade

  $scope.assignment = ()->
    AssignmentService.assignments[0]

  $scope.init = (assignmentId, recipientType, recipientId)->
    AssignmentService.getAssignment(assignmentId)
    GradeService.getGrade(assignmentId, recipientType, recipientId)

  $scope.toggleCustomValue = ()->
    GradeService.toggleCustomValue()
  $scope.enableCustomValue = ()->
    GradeService.enableCustomValue()
  $scope.enableScoreLevels = ()->
    GradeService.enableScoreLevels()
  $scope.justUpdated = ()->
    GradeService.justUpdated()
  $scope.timeSinceUpdate = ()->
    GradeService.timeSinceUpdate()
  $scope.updateGrade = ()->
    GradeService.updateGrade()

  $scope.froalaOptions = {
    inlineMode: false,
    heightMin: 200,
    toolbarButtons: [
      'fullscreen', 'bold', 'italic', 'underline', 'strikeThrough',
      'fontFamily', 'fontSize', 'color', 'sep', 'blockStyle', 'emoticons',
      'insertTable', 'sep', 'formatBlock', 'align', 'insertOrderedList',
      'outdent', 'indent', 'insertHorizontalRule', 'insertLink', 'undo', 'redo',
      'clearFormatting', 'selectAll', 'html'
    ]
  }
]
