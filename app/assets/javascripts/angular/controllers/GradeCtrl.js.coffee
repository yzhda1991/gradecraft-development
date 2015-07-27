@gradecraft.controller 'GradeCtrl', ['$rootScope', '$scope', 'GradePrototype', 'AssignmentScoreLevelPrototype', '$window', '$http', 'BadgePrototype', ($rootScope, $scope, GradePrototype, AssignmentScoreLevelPrototype, $window, $http, BadgePrototype) -> 

  $scope.init = (grade, assignmentScoreLevels, badges)->
    $scope.header = "waffles" 
    gradeParams = grade["grade"]
    $scope.grade = new GradePrototype(gradeParams, $http)

    gradeId = gradeParams.id
    $scope.rawScoreUpdating = false
    $scope.hasChanges = false
    $scope.gradeStatuses = ["In Progress", "Graded", "Released"]

    $scope.badges = []
    $scope.addBadges = (badges)->
      angular.forEach(badges, (badge, index)->
        badgePrototype = new BadgePrototype(badge)
        badgePrototype.addEarnedBadges()
        $scope.badges.push badgePrototype
      )

    $scope.assignmentScoreLevels = []
    $scope.addAssignmentScoreLevels = (assignmentScoreLevels)->
      angular.forEach(assignmentScoreLevels, (scoreLevel, index)->
        scoreLevelPrototype = new AssignmentScoreLevelPrototype(scoreLevel, $scope)
        $scope.assignmentScoreLevels.push scoreLevelPrototype
      )

    unless assignmentScoreLevels.length == undefined
      $scope.addAssignmentScoreLevels(assignmentScoreLevels)

    unless badges.length == undefined
      $scope.addBadges(badges)

    $scope.earnBadgeForStudent = (badge)->
      alert(badge.id)
      alert(badge.studentVisible)
      $http.post("/grades/earn_student_badge", $scope.earnedBadgePostParams(badge)).success(
        (data, status)->
          alert "badge earned!"
      )
      .error((err)->
        alert("create failed!")
        return false
      )
 
    $scope.earnedBadgePostParams = (badge)->
      earned_badge:
        student_id: $scope.grade.student_id
        badge_id: badge.id,
        grade_id: $scope.grade.id,
        assignment_id: $scope.grade.assignment_id
        score: badge.point_total

    $scope.froalaOptions = {
      inlineMode: false,
      minHeight: 100,
      buttons: [ "bold", "italic", "underline", "strikeThrough", "subscript", "superscript", "fontFamily", "fontSize", "color", "formatBlock", "blockStyle", "inlineStyle", "align", "insertOrderedList", "insertUnorderedList", "outdent", "indent", "selectAll", "createLink", "insertVideo", "table", "undo", "redo", "html", "save", "insertHorizontalRule", "removeFormat" ],

      #Set the save URL.
      saveURL: '/grades/' + gradeId + '/async_update',

      #HTTP request type.
      saveRequestType: 'PUT',

      # Additional save params.
      saveParams: {"save_type": "feedback"}
    }
]
