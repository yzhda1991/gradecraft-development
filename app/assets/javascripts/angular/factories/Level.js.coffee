@gradecraft.factory 'Level', ['$http', 'Restangular', 'LevelBadge', ($http, Restangular, LevelBadge) ->
  class Level
    constructor: (criterion, attrs={}, $scope)->
      @$scope = $scope
      @id = attrs.id or null
      @criterion = criterion
      @badges = {}
      @availableBadges = angular.copy($scope.courseBadges)
      @selectedBadge = ""
      @id = if attrs.id then attrs.id else null

      @loadLevelBadges(attrs["level_badges"]) if attrs["level_badges"] #add badges if passed on init
      @criterion_id = criterion.id
      @name = attrs.name or ""
      @editingBadges = false
      @points = attrs.points || 0
      @fullCredit = attrs.full_credit or false
      @noCredit = attrs.no_credit or false
      @meetsExpectations = attrs.meets_expectations || false
      @required = (attrs.full_credit || attrs.no_credit) || false
      @description = attrs.description or ""
      @resetChanges()

    isNew: ()->
      @id is null
    isSaved: ()->
      @id > 0
    change: ()->
      if @isSaved()
        @hasChanges = true
    alert: ()->
      alert("snakes!")
    resetChanges: ()->
      @hasChanges = false
    params: ()->
      criterion_id: @criterion_id,
      name: @name,
      points: @points,
      description: @description
    criterionName: ()->
      alert @criterion.name
    removeFromCriterion: (index)->
      @criterion.levels.splice(index,1)
    setCriterionExpectation: ()->
      angular.forEach(@criterion.levels,(level,i)=>
        level.meetsExpectations = false
      )
      @meetsExpectations = true

    ##rubric ctrl
    loadLevelBadge: (levelBadge)->
      courseBadge = @availableBadges[levelBadge.badge_id]
      loadedBadge = new LevelBadge(@, angular.copy(courseBadge))
      loadedBadge.id = levelBadge.id
      @badges[courseBadge.id] = loadedBadge # add level badge to level
      delete @availableBadges[courseBadge.id] # remove badge from available badges on level

    # Badges
    loadLevelBadges: (levelBadges)->
      angular.forEach(levelBadges, (levelBadge, index)=>
        if (@availableBadges[levelBadge.badge_id])
          @loadLevelBadge(levelBadge)
      )
    #rubric ctrl
    # Badges
    addBadge: (attrs={})->
      newBadge = new LevelBadge(@, attrs)
      @badges.splice(-1, 0, newBadge)
    addBadges: (levels)->
      angular.forEach(badges, (badge,index)=>
        @loadBadge(badge)
      )
    selectBadge: ()->
      newBadge = new LevelBadge(@, angular.copy(@selectedBadge), {create: true})

    deleteLevelBadge: (levelBadge)->
      if confirm("Are you sure you want to delete this badge from the level?")
        $http.delete("/level_badges/#{levelBadge.id}").success(
          (data,status)=>
            @availableBadges[levelBadge.badge.id] = angular.copy(@$scope.courseBadges[levelBadge.badge.id])
            delete @badges[levelBadge.badge.id]
        ).error((err)->
          alert("delete failed!")
        )

    resetChanges: ()->
      @hasChanges = false
    editBadges: ()->
      @editingBadges = true
    closeBadges: ()->
      @editingBadges = false
    params: ()->
      criterion_id: @criterion_id,
      name: @name,
      points: @points,
      description: @description
    create: ()->
      Restangular.all('levels').post(@params())
        .then(
          (response)=> #success
            @id = response.id
          (response)-> #error
        )
    modify: (form)->
      if form.$valid
        if @isNew()
          @create()
        else
          @update()

    update: ()->
      if @hasChanges
        Restangular.one('levels', @id).customPUT(@params())
          .then(
            ()-> #success
            ()-> #failure
          )
        @resetChanges()
    criterionName: ()->
      alert @criterion.name
    label: ()->
      if @noCredit
        "Zero Credit Level"
      else if @fullCredit
        "Full Credit Level"
      else if @meetsExpectations
        "Meets Expectations"
      else
        "" #used to say: "Score Level"

    # TODO: move all API calls to a service
    setAsMeetsExpectations: ()->
      $http.put("/api/levels/#{@id}", { level: { meets_expectations: true }})
        .success((data,status)=>
          @setCriterionExpectation()
          return true
        )
        .error((err)->
          console.log("Marking level as meets expectations failed")
          return false
        )
    removeMeetsExpectations: ()->
      $http.put("/api/levels/#{@id}", { level: { meets_expectations: false }})
        .success((data,status)=>
          @meetsExpectations = false
          return true
        )
        .error((err)->
          console.log("Removing level meets expectations failed")
          return false
        )
    delete: (index)->
      if @isSaved()
        if confirm("Are you sure you want to delete this level?")
          $http.delete("/levels/#{@id}")
          .success((data,status)=>
            @removeFromCriterion(index)
            return true
          )
          .error((err)->
            alert("delete failed!")
            return false
          )
      else
        @removeFromCriterion(index)
    removeFromCriterion: (index)->
      @criterion.levels.splice(index,1)
]
