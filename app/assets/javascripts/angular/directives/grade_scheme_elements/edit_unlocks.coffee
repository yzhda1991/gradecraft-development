@gradecraft.directive 'gradeSchemeElementEditUnlocks', ['GradeSchemeElementsService', 'UnlockConditionService', (GradeSchemeElementsService, UnlockConditionService) ->

  return {
    scope: {
      gradeSchemeElementId: "="
    }
    templateUrl: 'grade_scheme_elements/edit_unlocks.html',
  }
]
