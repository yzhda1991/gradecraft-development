@gradecraft.factory 'BadgePrototype', ['EarnedBadge', '$timeout', (EarnedBadge, $timeout)->
  class BadgePrototype

    constructor: (attrs, gradeId) ->
      @id = attrs.id
      @name = attrs.name
      @description = attrs.name
      @point_total = attrs.point_total
      @multiple = attrs.multiple
      @icon = attrs.icon
      @value = attrs.value
      @formatted_value = null
      @grade_id = gradeId
      @assignment_id = attrs.assignment_id
      @student_earned_badges_serial = attrs.student_earned_badges
      this.otherEarnedBadges = []
      this.earnedBadgesForGrade = []
      this.addEarnedBadges()
      @awarded = this.earnedBadgesForGrade.length > 0 ? true : false

    handleDestroyAll: ()->
      this.earnedBadgesForGrade = []
      $timeout(this.setAvailable, 300)

    deleteEarnedStudentBadge: ()->
      earnedBadge = this.earnedBadgesForGrade[0]
      if earnedBadge.deleteFromServer(this)
        this.earnedBadgesForGrade = []
        $timeout(this.setAvailable, 300)
        $timeout(this.hideAfterFadeOnDestroy, 1000)

    earnBadge: (params)->
      self = this
      earnedBadge = new EarnedBadge(params)
      if earnedBadge.grade_id == self.grade_id
        self.earnedBadgesForGrade.push earnedBadge
      else
        self.otherEarnedBadges.push earnedBadge

    addEarnedBadges: ()->
      self = this
      angular.forEach(@student_earned_badges_serial, (earnedBadgeParams, index)->
        self.earnBadge(earnedBadgeParams)
      )

    unearned: ()->
      this.earnedBadgesForGrade.length == 0

    setAwarded: ()->
      this.awarded = true

    setAvailable: ()->
      this.awarded = false
]
