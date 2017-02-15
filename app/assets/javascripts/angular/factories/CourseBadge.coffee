@gradecraft.factory 'CourseBadge', ['EarnedBadge', (EarnedBadge) ->
  class CourseBadge
    constructor: (attrs={}) ->
      if typeof attrs != "undefined"
        @id = attrs.id if attrs.id
        @name = attrs.name if attrs.name
        @description = attrs.description if attrs.description
        @full_points = attrs.full_points if attrs.full_points
        @icon = attrs.icon if attrs.icon
        @multiple = !!attrs.can_earn_multiple_times
  ]
