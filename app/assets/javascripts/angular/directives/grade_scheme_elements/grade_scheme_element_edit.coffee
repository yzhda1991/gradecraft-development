# Entry point for editing an grade_scheme_element
@gradecraft.directive 'gradeSchemeElementEdit', [() ->
  GradeSchemeElementEditCtrl = [()->
  ]

  {
    bindToController: true,
    controller: GradeSchemeElementEditCtrl,
    controllerAs: 'vmGradeSchemeElementEdit',
    templateUrl: 'grade_scheme_elements/grade_scheme_element_edit.html',
    scope: {
      gradeSchemeElementId: "="
    }
  }
]
