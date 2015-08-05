@gradecraft.factory 'EarnedBadge', ['$http', '$q', ($http, $q)->
  class EarnedBadge
    constructor: (attrs) ->
      @id = attrs.id
      @student_id = attrs.student_id
      @badge_id = attrs.badge_id
      @score = attrs.score
      @student_visible = attrs.student_visible
      @grade_id = attrs.grade_id

    deleteFromServer: (badge)->
      $http.delete(this.deletePath()).then ((response) ->
        if typeof response.data == 'object'
          response.data
          console.log "Successfully deleted Earned Badge"
        else
          # invalid response
          console.log "Failed to delete Earned Badge"
          $q.reject response.data
      ), (response) ->
        # something went wrong
        console.log "Error occurred while trying to delete badge."
        $q.reject response.data

    deletePath: ()->
      "/grade/" + this.grade_id + "/student/" + this.student_id + "/badge/" + this.badge_id + "/earned_badge/" + this.id

    deleteParams: ()->
      student_id: this.student_id,
      badge_id: this.badge_id,
      grade_id: this.grade_id
]
