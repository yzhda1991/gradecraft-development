@gradecraft.directive 'predictorAssignmentIcon', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      iconName: '='
      assignment: '='
    }
    templateUrl: 'ng_predictor_icons.html'
    link: (scope, el, attr)->
      scope.iconHtml = {
        late: {
          tooltip: 'This ' + PredictorService.termFor.assignment + ' is late!'
          icon: "fa-exclamation-triangle"
        }
        required: {
          tooltip: 'This ' + PredictorService.termFor.assignment + ' is required!'
          icon: "fa-star"
        }
        locked: {
          tooltip: 'This ' + PredictorService.termFor.assignment + ' is locked!'
          icon: "fa-lock"
        }
        unlocked: {
          tooltip: 'This ' + PredictorService.termFor.assignment + ' is unlocked!'
          icon: "fa-unlock-alt"
        }

      }
  }
]
