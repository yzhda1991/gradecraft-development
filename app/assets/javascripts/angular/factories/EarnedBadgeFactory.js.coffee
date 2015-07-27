@gradecraft.factory 'EarnedBadge', ['$http', ($http)->
  class EarnedBadge
    constructor: (attrs) ->
      @id = attrs.id
      @student_id = attrs.student_id
      @badge_id = attrs.badge_id
      @score = attrs.score
      @student_visible = attrs.student_visible
      @grade_id = attrs.grade_id

    deleteFromServer: (badge)->
      $http.delete('/earned_badges', this.deleteParams())
        .success(
          (data, status)->
            return true
        )
        .error((err)->
          return false
        )

    deleteParams: ()->
      student_id: this.student_id,
      badge_id: this.badge_id,
      grade_id: this.grade_id
]
