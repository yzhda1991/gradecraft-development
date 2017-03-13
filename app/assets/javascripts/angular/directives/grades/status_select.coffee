# Grade status selector for releasing grade to students

# We don't bind directly to the grade.status, as this could cause
# the grade status to update on autosave. Instead we bind to the
# grade.pending_status, which is set to the grade.status on the initial GET,
# and then used to upate the grade.status on final submit.

@gradecraft.directive 'gradeStatusSelect', ['GradeService', (GradeService) ->

  return {
    templateUrl: 'grades/status_select.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.modelGrade

      scope.statusOptions = ()->
        GradeService.gradeStatusOptions

  }
]
