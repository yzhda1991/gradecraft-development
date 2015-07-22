@gradecraft.factory 'GradePrototype', ->
  class GradePrototype
    constructor: (attrs={}, http)->
      @id = attrs.id
      @status = attrs.status
      @raw_score = attrs.raw_score
      @feedback = attrs.feedback
      @is_custom_value = attrs.is_custom_value
      @http = http
      @updated_at = null

    enableCustomValue: ()->
      if this.is_custom_value == false
        this.is_custom_value = true
        this.update()

    disableCustomValue: ()->
      if this.is_custom_value == true
        this.is_custom_value = false
        this.update()

    enableScoreLevels: (event)->
      event.preventDefault()
      event.stopPropagation()
      if this.is_custom_value == true
        this.is_custom_value = false
        this.update()

    modelOptions: ()->
      {
        updateOn: 'default blur',
        debounce: {
          default: 1800,
          blur: 0
        }
      }

    update: ()->
      self = this
      @http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
          self.updated_at = new Date()
      )
      .error((err)->
      )

    params: ()->
      {
        id: self.id,
        status: self.status,
        raw_score: this.raw_score,
        feedback: this.feedback,
        is_custom_value: this.is_custom_value
      }

