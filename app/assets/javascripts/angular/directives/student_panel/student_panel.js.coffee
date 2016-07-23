# .student-panel

# Main directive for the student side panel
@gradecraft.directive 'studentPanel', [ 'StudentPanelService', (StudentPanelService)->

  return {
    restrict: 'C'
    scope: {
      context: '='
    }
    templateUrl: 'student_panel/main.html'
    link: (scope, el, attr)->

      #---------------- PREDICTOR SIDE PANEL  ---------------------------------#

      scope.focusArticle = ()->
        StudentPanelService.focusArticle()

      scope.showingHint = ()->
        StudentPanelService.showingHint()

      scope.clearInfoHint = ()->
        StudentPanelService.clearInfoHint()

  }
]
