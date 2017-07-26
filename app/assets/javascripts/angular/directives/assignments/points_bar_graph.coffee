@gradecraft.directive 'assignmentPointsBarGraph', ['AssignmentTypeService', 'GradeSchemeElementsService', (AssignmentTypeService, GradeSchemeElementsService) ->

  return {
    scope: {
      assignmentType: "="
    }
    templateUrl: 'assignments/points_bar_graph.html',
    link: (scope, el, attr, ngModelCtrl)->

      scope.GradeSchemeElements = GradeSchemeElementsService.gradeSchemeElements

      scope.totalPoints = ()->
        GradeSchemeElementsService.totalPoints()

      scope.pointsOver = ()->
        @assignmentType.total_points > scope.totalPoints

      scope.pointsGraphStyle = ()->
        if scope.pointsOver(@assignmentType)
          "width: 100%; background: #D1495B"
        else
          "width: #{(@assignmentType.total_points / scope.totalPoints() * 100) }%"

      scope.pointsGraphStyleCapped = ()->
        "width: #{(@assignmentType.summed_assignment_points / scope.totalPoints * 100) }%; background: repeating-linear-gradient(-45deg, transparent, transparent 4px, #2E70BE 4px, #2E70BE 10px);"

      scope.pointsBeingCapped = () ->
        @assignmentType.is_capped && (@assignmentType.max_points < @assignmentType.summed_assignment_points)

      scope.pointsGraphPercentOfTotal = (gradeSchemeElement)->
        (gradeSchemeElement.lowest_points / scope.totalPoints() * 100) + "%"

  }
]

