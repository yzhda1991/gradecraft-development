@gradecraft.factory 'EarnedBadge', ['$http', '$q', ($http, $q)->
  class EarnedBadge
    constructor: (attrs) ->
      @id = attrs.id
      @student_id = attrs.student_id
      @badge_id = attrs.badge_id
      @points = attrs.points
      @student_visible = attrs.student_visible
      @grade_id = attrs.grade_id

    deleteFromServer: (badge)->
      $http.delete(this.deletePath()).then ((response) ->
        if typeof response.data == 'object'
          console.log "Successfully deleted Earned Badge"
          response.data
        else
          # invalid response
          console.log "Failed to delete Earned Badge"
          $q.reject response.data
      ), (response) ->
        # something went wrong
        console.log "Error occurred while trying to delete badge."
        $q.reject response.data

    deletePath: ()->
      "/api/earned_badges/" + this.id
]
