@gradecraft.directive 'assignmentPointsBarGraph', ['AssignmentService', 'AssignmentTypeService', 'GradeSchemeElementsService', (AssignmentService, AssignmentTypeService, GradeSchemeElementsService) ->

  return {
    scope: {
      assignmentType: "="
    }
    templateUrl: 'assignments/points_bar_graph.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.GradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements

      scope.totalPoints = ()->
        GradeSchemeElementsService.totalPoints()

      scope.sumForAssignmentType = ()->
        AssignmentService.sumForAssignmentType(@assignmentType.id)

      scope.pointsOver = ()->
        scope.sumForAssignmentType() > scope.totalPoints()

      scope.pointsGraphStyle = ()->
        if scope.pointsOver(@assignmentType)
          "width: 100%; background: #D1495B"
        else
          "width: #{(scope.sumForAssignmentType() / scope.totalPoints() * 100) }%"

      scope.pointsGraphStyleCapped = ()->
        "width: #{(scope.sumForAssignmentType() / scope.totalPoints * 100) }%; background: repeating-linear-gradient(-45deg, transparent, transparent 4px, #2E70BE 4px, #2E70BE 10px);"

      scope.pointsBeingCapped = () ->
        @assignmentType.is_capped && (@assignmentType.max_points <  scope.sumForAssignmentType())

      scope.pointsGraphPercentOfTotal = (gradeSchemeElement)->
        (gradeSchemeElement.lowest_points / scope.totalPoints() * 100) + "%"

  }
]

