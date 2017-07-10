@gradecraft.directive 'unlockCondition', ['UnlockConditionService', (UnlockConditionService) ->

  return {
    scope: {
      condition: "=",
    },
    templateUrl: 'unlock_conditions/unlock_condition.html',

    link: (scope, el, attr)->

      scope.termFor = (item)->
        UnlockConditionService.termFor(item)

      scope.removeCondition = (index)->
        UnlockConditionService.removeCondition(index)

      scope.conditionIsValid = ()->
        UnlockConditionService.conditionIsValid(scope.condition)

      scope.changeConditionType = ()->
        UnlockConditionService.changeConditionType(scope.condition)

      scope.conditionTypes = ["Assignment Type", "Assignment", "Badge", "Earned Point Value"]

      scope.conditionsTypeTranslation = (type)->
        switch type
          when  "Earned Point Value" then "Course"
          when "Assignment Type" then "AssignmentType"
          else type

      scope.assignments = UnlockConditionService.assignments
      scope.assignmentStates = (assignmentId)->
        assignment = _.find(UnlockConditionService.assignments, {id: assignmentId})
        if assignment && assignment.pass_fail
          ["Submitted", "Feedback Read", "Passed"]
        else
          ["Submitted", "Feedback Read", "Grade Earned"]

      scope.badges = UnlockConditionService.badges

      scope.assignmentTypes = UnlockConditionService.assignmentTypes
      scope.assignmentTypeStates = ["Assignments Completed", "Minimum Points Earned"]

  }
]

