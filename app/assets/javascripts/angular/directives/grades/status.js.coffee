# Grade status selector for releasing grade to students

@gradecraft.directive 'gradeStatus', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/status.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.statusOptions = ()->
        GradeService.gradeStatusOptions

  }
]
