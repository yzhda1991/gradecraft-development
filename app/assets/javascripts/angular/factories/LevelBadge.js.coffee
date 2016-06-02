@gradecraft.factory 'LevelBadge', ['$http', ($http) ->
  class LevelBadge
    constructor: (level, badge, attrs={create:false}) ->
      @level = level
      @badge = badge
      if badge.name
        @name = badge.name
      @level_id = level.id
      @badge_id = badge.id
      @description = badge.description
      @full_points = badge.full_points
      @icon = badge.icon
      @multiple = badge.multiple
      @id = null
      if attrs.create
        @create()

    create: ()->
      $http.post("/level_badges", @createParams()).success(
        (data,status)=>
          @id = data.existing_level_badge.id
          @level.badges[@badge_id] = @ # add level badge to level
          delete @level.availableBadges[@badge_id] # remove badge from available badges on level
          #self.selectedBadge = "" # reset selected badge
      ).error((err)->
        alert("create failed!")
        return false
      )

    createParams: ()->
      level_id: @level.id,
      badge_id: @badge.id
]
