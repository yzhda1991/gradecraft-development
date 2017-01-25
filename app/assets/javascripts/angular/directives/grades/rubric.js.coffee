# rubric controlled raw_points

@gradecraft.directive 'gradeRubric', ['GradeService', 'RubricService', (GradeService, RubricService) ->

  return {
    templateUrl: 'grades/rubric.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade
      scope.rubric = RubricService.rubric
      scope.criteria = RubricService.criteria

      scope.gradeForCriterion = (criterionId)->
        GradeService.findCriterionGrade(criterionId) || GradeService.addCriterionGrade(criterionId)

      scope.badgesForLevel = (level)->
        RubricService.badgesForLevel(level)

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.queueUpdateCriterionGrade = (criterion, immediate)->
        GradeService.queueUpdateCriterionGrade(criterion.id, immediate)

      scope.selectLevel = (criterion, level)->
        GradeService.setCriterionGradeLevel(criterion.id, level)
        GradeService.queueUpdateCriterionGrade(criterion.id)

      scope.LevelIsSelected = (criterion,level)->
        criterionGrade = GradeService.findCriterionGrade(criterion.id)
        return false if !criterionGrade
        criterionGrade.level_id == level.id

      scope.levelMeetExpectations = (criterion, level)->
        return false if ! criterion.meets_expectations_level_id
        level.points >= criterion.meets_expectations_points

  }
]
