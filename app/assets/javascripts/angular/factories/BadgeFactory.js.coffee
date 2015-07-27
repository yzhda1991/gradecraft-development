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
]
