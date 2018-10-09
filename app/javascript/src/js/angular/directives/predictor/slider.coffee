# Slider component for Predicted Points on Assignments, Challenges and Badges.
# Zeros out predictions below threshold values, and snaps to Levels.
#
# The component slider instantiates a jquery ux slider with custom angular
# overrides.  Below the slider there is a input field where the value can be
# directly entered.  This requires careful binding to the Angular model,
# since binding the model directly to the slider causes updates to the slider
# to trigger events as if the slider was dragged manually. Updates to the
# components are handled manually with a registerd input mode, and timeout
# functions to avoid clobbering the updates occuring outside of the slider
# component.

@gradecraft.directive 'componentSlider', [ '$timeout', 'PredictorService', ($timeout, PredictorService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'predictor/components/slider.html'

    link: (scope, el, attr)->


      #---------------- DOM AND MODEL SYNCING  --------------------------------#

      # Set and Query the input mode (text field input or slider drag).
      # Only trigger slider events when the mode is 'SLIDER'.
      # Set the mode to 'TEXT_INPUT' before managing text field inputs, and
      # then set back to 'SLIDER' in a timeout after API update call is sent.
      scope.inputMode = (mode)->
        if mode
          return scope.mode = mode
        else
          if scope.mode && scope.mode == "TEXT_INPUT"
            return "TEXT_INPUT"
          else
            return scope.mode = "SLIDER"

      # updates predicted points on article model
      scope.updateArticle = (points)->
        scope.$apply(()->
          scope.article.prediction.predicted_points = points
        )

      # updates position of the slider in the DOM
      scope.updateSlider = (points)->
        el.slider("value", points)

      # Makes API call, and resets the input mode
      scope.save = ()->
        PredictorService.postPredictedArticle(scope.article)

        # Avoids conflict from event watchers on slider when manually
        # setting value from input text field.
        setTimeout ( ->
          scope.inputMode("SLIDER")
        ), 125

      #---------------- THRESHOLDS --------------------------------------------#

      # prediction is below threshold points?
      scope.pointsAreBelowThreshold = (points)->
        @article.has_threshold && points < @article.threshold_points

      # add css class to sliders below threshold
      scope.uxThresholdClass = (points)->
        if scope.pointsAreBelowThreshold(points)
          el.addClass("below-threshold")
        else
          el.removeClass("below-threshold")


      #---------------- SCORE LEVELS ------------------------------------------#

      # returns closest score level to supplied points,
      # assumes article.has_levels
      scope.closestScoreLevel = (points)->
        scoreLevels = @article.score_levels || []
        closest = null
        _.each(scoreLevels, (lvl,i)->
          if (closest == null || Math.abs(lvl.points - points) < Math.abs(scoreLevels[closest].points - points))
            closest = i
        )
        return scoreLevels[closest]

      # Points are close to a score level?
      scope.pointsAreInLevelRange = (points)->
        return false unless @article.has_levels
        tolerance = @article.full_points * 0.05
        if Math.abs(scope.closestScoreLevel(points).points - el.slider("value")) <= tolerance
          return true
        else
          return false

      # Returns the Level Name if predicted score in range
      scope.levelNameForArticleScore = ()->
        if scope.pointsAreInLevelRange(el.slider("value"))
          return scope.closestScoreLevel(el.slider("value")).name
        else
          return ""


      #---------------- SNAPPING POINTS ---------------------------------------#

      # keep predicted points between 0 and article full points
      scope.pointsSnappedToRange = (points)->
        if points < 0
          return 0
        if points > @article.full_points
          return @article.full_points
        return points

      # move points to score levels points value when in range
      scope.pointsSnappedToScoreLevel = (points)->
        if scope.pointsAreInLevelRange(points)
          scope.closestScoreLevel(points).points
        else
          return points

      # points below threshold revert to zero
      scope.pointsSnappedToThreshold = (points)->
        if scope.pointsAreBelowThreshold(points)
          return 0
        else
          return points

      # Only snaps that we want to fire while live updates
      # are coming from the input field
      scope.liveSnap = (points)->
        points = scope.pointsSnappedToRange(points)
        scope.updateArticle(points)
        scope.updateSlider(points)

      scope.snapAndSave = (points)->
        points = if isNaN(points) then 0 else points
        points = scope.pointsSnappedToRange(points)
        points = scope.pointsSnappedToScoreLevel(points)
        points = scope.pointsSnappedToThreshold(points)
        scope.updateArticle(points)
        scope.updateSlider(points)
        scope.save()

      #---------------- DIRECT INPUT FIELD ------------------------------------#

      # snap and persist input value on blur
      scope.registerInput = ()->
        scope.inputMode("TEXT_INPUT")

        # Wait for the current $apply in progress to complete
        setTimeout ( ->
          scope.snapAndSave(scope.article.prediction.predicted_points)
        ), 125

      # register and snap updates while typing in the input field
      scope.registerInputChanging = ()->
        scope.inputMode("TEXT_INPUT")

        setTimeout ( ->
          scope.liveSnap(scope.article.prediction.predicted_points)
        ), 125


      #------------- SLIDER ELEMENT -------------------------------------------#

      # Creates slider element and Manages presets and event handling
      el.slider({

        # jquery ui slider presets

        range: "min"
        value: parseInt(scope.article.prediction.predicted_points)
        min: 0
        max: parseInt(scope.article.full_points)

        # event handling

        slide: (event, ui)->
          # NOTE: THESE ARE NOT THE SAME!
          # console.log(ui.value + " !== " + el.slider("value"));
          if scope.inputMode() == "SLIDER"
            scope.uxThresholdClass(ui.value)
            scope.updateArticle(ui.value)

        stop: (event, ui)->
          if scope.inputMode() == "SLIDER"
            scope.snapAndSave(ui.value)
      })
  }
]
