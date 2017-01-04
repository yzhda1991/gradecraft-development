# status selector for student visibility
@gradecraft.directive 'gradeStatus', ['AssignmentService', 'GradeService', (AssignmentService, GradeService) ->

  return {
    templateUrl: 'grades/status.html'
    link: (scope, el, attr)->

      scope.assignment = ()->
        AssignmentService.assignment()

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.statusOptions = ()->
        return [] if !scope.assignment()
        if scope.assignment().release_necessary
          ["In Progress", "Graded", "Released"]
        else
          ["In Progress", "Graded"]

  }
]
