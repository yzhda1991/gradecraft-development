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
      @creating = false
      @deleting = false

    handleDestroyAll: ()->
      this.earnedBadgesForGrade = []
      $timeout(this.setAvailable, 300)

    deleteEarnedStudentBadge: ()->
      unless this.deleting == true
        this.setDeleting()
        earnedBadge = this.earnedBadgesForGrade[0]
        if earnedBadge.deleteFromServer(this)
          this.earnedBadgesForGrade = []
          $timeout(this.setAvailable, 300)

    earnBadge: (params)->
      self = this
      earnedBadge = new EarnedBadge(params)
      if earnedBadge.grade_id == self.grade_id
        alert("grade id matches")
        self.earnedBadgesForGrade.push earnedBadge
        alert(self.earnedBadgesForGrade.length)
      else
        self.otherEarnedBadges.push earnedBadge

    addEarnedBadges: ()->
      self = this
      angular.forEach(@student_earned_badges_serial, (earnedBadgeParams, index)->
        self.earnBadge(earnedBadgeParams)
      )

    unearned: ()->
      this.earnedBadgesForGrade.length == 0

    timeoutCreate: ()->
      `$timeout(function() {this.creating = false}, 1000);`

    setAwarded: ()->
      this.awarded = true

    setAvailable: ()->
      this.awarded = false
      this.deleting = false

    setCreating: ()->
      this.creating = true

    createDone: ()->
      this.creating = false

    setDeleting: ()->
      this.deleting = true

    deleteDone: ()->
      this.deleting = false

]
