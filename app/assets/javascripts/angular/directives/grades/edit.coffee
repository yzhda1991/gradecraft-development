# Main entry point for grading (standard/rubric individual/group)
# Renders appropriate grading form for grade and assignment type

@gradecraft.directive 'gradeEdit', ['$q', 'AssignmentService', 'GradeService', 'RubricService',
  ($q, AssignmentService, GradeService, RubricService) ->
    EditGradeCtrl = [() ->
      vm = this

      vm.loading = true
      vm.GradeService = GradeService
      vm.AssignmentService = AssignmentService
      vm.termFor = AssignmentService.termFor

      # This can be simplified once group grades can also handle grade file uploads
      vm.feedbackMessage =
        if vm.recipientType == "group" then "Enter Text Feedback" else "Upload Feedback or Enter Below"

      services(@assignmentId, @recipientType, @recipientId, @rubricId).then(() ->
        vm.loading = false

        # Set a default state for new pass/fail grades, so that the
        # Pass/Fail switch corresponds to the grade state on init.
        if AssignmentService.assignment().pass_fail && !GradeService.modelGrade.pass_fail_status
          GradeService.setGradeToPass()
      )

      _rawPointsType = () ->
        assignment = AssignmentService.assignment()
        return "" if !assignment

        if assignment.is_rubric_graded == true
          return "RUBRIC"
        if assignment.pass_fail == true
          return "PASS_FAIL"
        if assignment.score_levels
          "SCORE_LEVELS"
        else
          "DEFAULT"

      vm.isGroupGrade = vm.recipientType == "group"
      vm.isStandardGraded = () ->
        _rawPointsType() == "DEFAULT"
      vm.isRubricGraded = ()->
        _rawPointsType() == "RUBRIC"
      vm.isPassFailGraded = () ->
        _rawPointsType() == "PASS_FAIL"
      vm.isScoreLevelGraded = () ->
        _rawPointsType() == "SCORE_LEVELS"
    ]

    services = (assignmentId, recipientType, recipientId, rubricId) ->
      promises = [
        AssignmentService.getAssignment(assignmentId)
        GradeService.getGrade(assignmentId, recipientType, recipientId)
      ]
      promises.push(RubricService.getRubric(rubricId)) if rubricId?
      $q.all(promises)

    {
      bindToController: true
      controller: EditGradeCtrl
      controllerAs: 'vm'
      scope:
         assignmentId: "="
         rubricId: '='
         recipientType: "@"
         recipientId: "="
         submitPath: "@"
         gradeNextPath: "@"
         isActiveCourse: "="
         hasAwardableBadges: "="
         courseHasLearningObjectives: "="
      templateUrl: 'grades/edit.html'
    }
]
