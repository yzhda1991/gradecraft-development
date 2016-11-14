@gradecraft.factory 'Grade', ['$http', 'EventHelper', (EventHelper)->
  class Grade
    constructor: (attrs={}, http)->
      @id = attrs.id
      @status = attrs.status
      @raw_points = attrs.raw_points
      @feedback = attrs.feedback
      @is_custom_value = attrs.is_custom_value || false
      @student_id = attrs.student_id
      @assignment_id = attrs.assignment_id
      @releaseNecessary = attrs.assignment.release_necessary
      @student_visible = attrs.student_visible
      @http = http
      @updated_at = null

    # updating grade properties
    update: ()->
      self = this
      $http.put("/api/grades/#{self.id}", grade: self).success(
        (data,status)->
          console.log(data);
          self.updated_at = new Date()
      )
      .error((err)->
        console.log(err);
      )

    params: ()->
      {
        id: self.id,
        raw_points: this.raw_points,
        feedback: this.feedback,
        is_custom_value: this.is_custom_value
      }

]
