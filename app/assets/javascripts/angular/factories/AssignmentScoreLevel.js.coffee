@gradecraft.factory 'AssignmentScoreLevel', ['NumberHelper', (NumberHelper)->
  class AssignmentScoreLevel

    constructor: (attrs) ->
      @id = attrs.id
      @value = attrs.points
      @formatted_value = null
      @name = attrs.name
      @assignment_id = attrs.assignment_id
      this.cacheFormattedValue()

    cacheFormattedValue: ()->
      @formatted_value = NumberHelper.addCommas(@value)

]
