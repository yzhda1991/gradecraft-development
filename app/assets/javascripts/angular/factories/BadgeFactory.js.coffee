@gradecraft.factory 'BadgePrototype', ['EarnedBadge', (EarnedBadge)->
  class BadgePrototype

    constructor: (attrs) ->
      @id = attrs.id
      @name = attrs.name
      @description = attrs.name
      @point_total = attrs.point_total
      @multiple = attrs.multiple
      @icon = attrs.icon
      @value = attrs.value
      @formatted_value = null
      @assignment_id = attrs.assignment_id
      @student_earned_badges_serial = attrs.student_earned_badges
      this.earnedBadges = []

    addEarnedBadges: ()->
      self = this
      angular.forEach(@student_earned_badges_serial, (earnedBadgeParams, index)->
        earnedBadge = new EarnedBadge(earnedBadgeParams)
        self.earnedBadges.push earnedBadge
      )

    earnBadgeUrl: (grade)->
      "/grades/" + grade.id + "/earn_badge"

    earnForStudent: (studentId, grade)->
      self = this
 
      $http.post(earnBadgeUrl(grade), self.earnedBadgePostParams(grade)).success(
        (data, status)->
          self.id = data.existing_metric_badge.id
      )
      .error((err)->
        alert("create failed!")
        return false
      )
 
      earnedBadgePostParams: (grade)->
        badge_id: this.badge.id,
        student_id:attrs.student_id,
        badge_id: attrs.score,
        student_visible: attrs.student_visible,
        grade_id: grade.id,
        assignment_id: grade.assignmentId
]
