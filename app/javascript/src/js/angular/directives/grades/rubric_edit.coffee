# rubric controlled raw_points

@gradecraft.directive 'gradeRubricEdit', ['GradeService', 'RubricService', (GradeService, RubricService) ->

  return {
    templateUrl: 'grades/rubric_edit.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.modelGrade
      scope.rubric = RubricService.rubric
      scope.criteria = RubricService.criteria

      scope.gradeForCriterion = (criterionId)->
        GradeService.findCriterionGrade(criterionId) || GradeService.addCriterionGrade(criterionId)

      scope.criterionLevels = (criterion)->
        RubricService.criterionLevels(criterion)

      scope.badgesForLevel = (level)->
        GradeService.criterionGrades
        RubricService.badgesForLevel(level)

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.queueUpdateCriterionGrade = (criterion, immediate)->
        GradeService.queueUpdateCriterionGrade(criterion.id, immediate)

      scope.selectLevel = (criterion, level)->
        if scope.LevelIsSelected(criterion,level)
          GradeService.unsetCriterionGrade(criterion.id)
        else
          GradeService.setCriterionGradeLevel(criterion.id, level)
        GradeService.queueUpdateCriterionGrade(criterion.id)

      scope.LevelIsSelected = (criterion,level)->
        criterionGrade = GradeService.findCriterionGrade(criterion.id)
        return false if !criterionGrade
        criterionGrade.level_id == level.id

      scope.levelMeetExpectations = (criterion, level)->
        return false if ! criterion.meets_expectations_level_id
        level.points >= criterion.meets_expectations_points

      scope.froalaOptions = {
        heightMin: 100,
        placeholderText: 'Enter Feedback for Criterion...',
      }

  }
]
