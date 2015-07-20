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
      assignment: '='
    }
    templateUrl: 'ng_predictor_switch.html'
    link: (scope, el, attr)->
      scope.passFailSwitchState = (assignment)->
        state = if assignment.grade.predicted_score == 0 then 'off' else 'on'
      scope.textForSwitch = (assignment)->
        if assignment.grade.predicted_score == 0 then PredictorService.termFor["fail"] else PredictorService.termFor["pass"]
      scope.toggleSwitch = (assignment,event)->
        assignment.grade.predicted_score = if assignment.grade.predicted_score == 0 then 1 else 0
        PredictorService.postPredictedScore(assignment.id,assignment.grade.predicted_score)
  }
]
