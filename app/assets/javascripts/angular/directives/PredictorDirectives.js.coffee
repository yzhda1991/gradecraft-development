@gradecraft.directive 'predictorArticleIcon', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      iconName: '='
      target: '='
      targetType: '@'
    }
    templateUrl: 'ng_predictor_icons.html'
    link: (scope, el, attr)->
      scope.targetTerm = ()->
        if @targetType == "assignment"
          PredictorService.termFor.assignment
        else if @targetType == "badge"
          PredictorService.termFor.badge
        else
          "item"

      scope.description = ()->
        if @target.description
          return @target.description
        else
          return ""

      scope.conditions = ()->
        @target.unlock_conditions

      scope.keys = ()->
        @target.unlock_keys

      scope.iconHtml = {
        late: {
          tooltip: 'This ' + scope.targetTerm() + ' is late!'
          icon: "fa-exclamation-triangle"
        }
        required: {
          tooltip: 'This ' + scope.targetTerm() + ' is required!'
          icon: "fa-star"
        }
        info: {
          tooltip: scope.description()
          icon: "fa-info-circle"
        }
        locked: {
          tooltip: scope.conditions()
          icon: "fa-lock"
        }
        unlocked: {
          tooltip: scope.conditions()
          icon: "fa-unlock-alt"
        }
        condition: {
          tooltip: scope.keys()
          icon: "fa-key"
        }
      }
  }
]

@gradecraft.directive 'predictorBinarySwitch', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
      targetType: '@'
      onValue: '='
      offValue: '='
    }
    templateUrl: 'ng_predictor_switch.html'
    link: (scope, el, attr)->
      scope.switchState = ()->
        if @targetType == 'assignment'
          if @target.grade.predicted_score == @offValue then 'off' else 'on'
        else if @targetType == 'badge'
          if @target.prediction.times_earned == 0 then 'off' else 'on'

      scope.textForSwitch = ()->
        if @targetType == 'assignment'
          if @target.pass_fail
            if @target.grade.predicted_score == @offValue then PredictorService.termFor["fail"] else PredictorService.termFor["pass"]
          else
            if @target.grade.predicted_score == @offValue then @offValue else @onValue
        else if @targetType == 'badge'
          if @target.prediction.times_earned == 0 then @offValue else @onValue

      scope.toggleSwitch = ()->
        if @targetType == 'assignment'
          @target.grade.predicted_score = if @target.grade.predicted_score == @offValue then @onValue else @offValue
          PredictorService.postPredictedGrade(@target.id,@target.grade.predicted_score)
        else if @targetType == 'badge'
          @target.prediction.times_earned = if @target.prediction.times_earned == 0 then 1 else 0
          PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
  }
]

@gradecraft.directive 'predictorCounterSwitch', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'ng_predictor_counter.html'
    link: (scope, el, attr)->
      scope.atMin = ()->
        @target.prediction.times_earned <= @target.earned_badge_count
      scope.increment = ()->
        @target.prediction.times_earned += 1
        PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
      scope.decrement = ()->
        if scope.atMin()
          return false
        else
          @target.prediction.times_earned -= 1
          PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
  }
]

@gradecraft.directive 'predictorAssignmentTypeWeights', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'ng_predictor_weights.html'
    link: (scope, el, attr)->
      scope.increment = ()->
        @target.student_weight += 1
        PredictorService.postAssignmentTypeWeight(@target.id,@target.student_weight)
      scope.decrement = ()->
        @target.student_weight -= 1
        PredictorService.postAssignmentTypeWeight(@target.id,@target.student_weight)
      scope.unusedWeights = ()->
        _.range(PredictorService.weights.unusedWeights())
      scope.usedWeights = ()->
        _.range(@target.student_weight)
      scope.weightsAvailable = ()->
        if @target.student_weight < 1
          return false if PredictorService.weights.unusedTypes() < 1
        if PredictorService.weights.max_weights
          @target.student_weight < PredictorService.weights.max_weights && PredictorService.weights.unusedWeights() > 0
        else
          PredictorService.weights.unusedWeights() > 0
      scope.hasWeights = ()->
        @target.student_weight > 0
      scope.weightsOpen = ()->
        PredictorService.weights.open
      scope.defaultMultiplier = ()->
        PredictorService.weights.default_weight
  }
]
