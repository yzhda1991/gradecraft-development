@gradecraft.directive 'predictorAssignmentIcon', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      iconName: '='
      assignment: '='
    }
    templateUrl: 'ng_predictor_icons.html'
    link: (scope, el, attr)->
      assignmentTerm = PredictorService.termFor.assignment
      scope.iconHtml = {
        late: {
          tooltip: 'This ' + assignmentTerm + ' is late!'
          icon: "fa-exclamation-triangle"
        }
        required: {
          tooltip: 'This ' + assignmentTerm + ' is required!'
          icon: "fa-star"
        }
        info: {
          tooltip: scope.assignment.description
          icon: "fa-info-circle"
        }
        locked: {
          tooltip: 'This ' + assignmentTerm + ' is locked!'
          icon: "fa-lock"
        }
        unlocked: {
          tooltip: 'This ' + assignmentTerm + ' is unlocked!'
          icon: "fa-unlock-alt"
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
