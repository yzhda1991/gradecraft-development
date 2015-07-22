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

@gradecraft.directive 'predictorPassFailSwitch', [ 'PredictorService', (PredictorService)->

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
          if @target.predicted_score == @offValue then 'off' else 'on'

      scope.textForSwitch = ()->
        if @targetType == 'assignment'
          if @target.pass_fail
            if @target.grade.predicted_score == @offValue then PredictorService.termFor["fail"] else PredictorService.termFor["pass"]
          else
            if @target.grade.predicted_score == @offValue then @offValue else @onValue
        else if @targetType == 'badge'
          if @target.predicted_score == @offValue then @offValue else @onValue

      scope.toggleSwitch = ()->
        if @targetType == 'assignment'
          @target.grade.predicted_score = if @target.grade.predicted_score == @offValue then @onValue else @offValue
          PredictorService.postPredictedScore(@target.id,@target.grade.predicted_score)
        else if @targetType == 'badge'
          @target.predicted_score = if @target.predicted_score == @offValue then @onValue else @offValue
          console.log("badge-toggle");
  }
]
