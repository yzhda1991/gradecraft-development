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
      _this = @
      $http.post("/level_badges", @createParams()).then(
        (response)->
          _this.id = response.data.id
          _this.level.badges[_this.badge_id] = _this
          delete _this.level.availableBadges[_this.badge_id]
          console.log(response.statusText)
          console.log(response.data)
        ,(response) ->
          console.log(response);
          return false
      )

    createParams: ()->
      level_id: @level.id,
      badge_id: @badge.id
]
