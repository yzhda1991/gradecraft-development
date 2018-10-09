# +/- counter component for Predicted Points Badges.
#
# Displays the number of times earned x points, and total earned
# When Badge has no points earnable, displays "won't earn" or "will earn x times"
# Or the number of times currently earned.
#
# Disabled minus button at zero or number of times actually earned, whichever greater.

@gradecraft.directive 'predictorCounterSwitch', [ 'PredictorService', (PredictorService)->

  return {
    scope: {
      article: '='
    }
    templateUrl: 'predictor/components/counter.html'
    link: (scope, el, attr)->
      scope.atMin = ()->
        @article.prediction.predicted_times_earned <= @article.earned_badge_count
      scope.textForTotal = ()->
        if @article.full_points == 0
          ""
        else
          @article.prediction.predicted_times_earned * @article.full_points
      scope.textForSwitch = ()->
        if @article.full_points == 0
          if scope.atMin()
            switch @article.prediction.predicted_times_earned
              when 0 then "won't earn"
              when 1 then "earned 1 time"
              else "earned " + @article.prediction.predicted_times_earned + " times"
          else
            if @article.prediction.predicted_times_earned == 1
              "will earn 1 time"
            else
              "will earn " + @article.prediction.predicted_times_earned + " times"
        else
          @article.prediction.predicted_times_earned + " x " + @article.full_points
      scope.increment = ()->
        @article.prediction.predicted_times_earned += 1
        PredictorService.postPredictedArticle(@article)
      scope.decrement = ()->
        if scope.atMin()
          return false
        else
          @article.prediction.predicted_times_earned -= 1
          PredictorService.postPredictedArticle(@article)
  }
]
