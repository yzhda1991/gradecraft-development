# Grade status selector for releasing grade to students

# We don't allow auto-updates on grade status,
# this could release a grade prematurely

@gradecraft.directive 'gradeStatusSelect', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/status_select.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade

      scope.statusOptions = ()->
        GradeService.gradeStatusOptions

  }
]
