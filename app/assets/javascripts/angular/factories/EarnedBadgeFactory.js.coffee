@gradecraft.factory 'EarnedBadge', ()->
  class EarnedBadge
    constructor: (attrs) ->
      @id = attrs.id
      @student_id = attrs.student_id
      @badge_id = attrs.score
      @student_visible = attrs.student_visible
      @grade_id = attrs.grade_id
