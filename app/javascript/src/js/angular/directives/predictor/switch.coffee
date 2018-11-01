# Binary switch for predicting Pass/Fail assignments and badges earnable only once

gradecraft.directive 'predictorBinarySwitch', [ 'PredictorService', (PredictorService)->

  return {
    scope: {
      article: '='
      onValue: '='
      offValue: '='
    }
    templateUrl: 'predictor/components/switch.html'

    link: (scope, el, attr)->

      scope.switchState = ()->
        if @article.type == 'assignments'
          if @article.prediction.predicted_points == @offValue then 'off' else 'on'
        else if @article.type == 'badges'
          if @article.prediction.predicted_times_earned == 0 then 'off' else 'on'

      scope.textForSwitch = ()->
        if @article.type == 'assignments'
          if @article.pass_fail
            if @article.prediction.predicted_points == @offValue then \
              PredictorService.termFor("fail") else PredictorService.termFor("pass")
          else
            if @article.prediction.predicted_points == @offValue then @offValue else @onValue
        else if @article.type == 'badges'
          if @article.full_points == 0
            if @article.prediction.predicted_times_earned == 0 then "won't earn" else "will earn"
          else
            if @article.prediction.predicted_times_earned == 0 then @offValue else @onValue

      scope.toggleSwitch = ()->
        if @article.type == 'assignments'
          @article.prediction.predicted_points =
            if @article.prediction.predicted_points == @offValue then @onValue else @offValue
        else if @article.type == 'badges'
          @article.prediction.predicted_times_earned = \
            if @article.prediction.predicted_times_earned == 0 then 1 else 0
        PredictorService.postPredictedArticle(@article)
  }
]
