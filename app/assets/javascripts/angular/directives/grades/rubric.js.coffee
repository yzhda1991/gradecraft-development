# rubric controlled raw_points

@gradecraft.directive 'gradeRubric', ['GradeService', 'RubricService', (GradeService, RubricService) ->

  return {
    templateUrl: 'grades/rubric.html'
    link: (scope, el, attr)->

      scope.grade = GradeService.grade
      scope.rubric = RubricService.rubric
      scope.criteria = RubricService.criteria

      scope.queueUpdateGrade = (immediate)->
        GradeService.queueUpdateGrade(immediate)

      scope.queueUpdateCriterionGrade = (criterion, immediate)->
        GradeService.queueUpdateCriterionGrade(immediate)

      scope.selectLevel = (level)->
        console.log("selectLevel")

      scope.LevelIsSelected = (criterion,level)->
        criterionGrade = _.find(GradeService.criterionGrades,{criterion_id: criterion.id})
        return false if !criterionGrade
        criterionGrade.level_id == level.id

      scope.levelMeetExpectations = (level)->
        console.log("levelMeetExpectations")

  }
]
