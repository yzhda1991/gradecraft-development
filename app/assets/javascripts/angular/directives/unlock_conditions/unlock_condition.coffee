@gradecraft.directive 'unlockCondition', ['UnlockConditionService', (UnlockConditionService) ->

  return {
    scope: {
      condition: "="
    },
    templateUrl: 'unlock_conditions/unlock_condition.html',

    link: (scope, el, attr)->

      scope.termFor = (item)->
        UnlockConditionService.termFor(item)

      scope.updateCondition = ()->
        UnlockConditionService.queueUpdateCondition(@condition)

      scope.removeCondition = ()->
        UnlockConditionService.removeCondition(@condition)

      scope.conditionIsValid = ()->
        UnlockConditionService.conditionIsValid(@condition)

      scope.changeConditionType = ()->
        UnlockConditionService.changeConditionType(@condition)

      scope.conditionsTypeTranslation = (type)->
        switch type
          when  "Earned Point Value" then "Course"
          when "Assignment Type" then "AssignmentType"
          when "Learning Objective" then "LearningObjective"
          else type

      # in the UnlockConditionService
      # a datepickerId is assigned to each criterion on load or when created,
      # and does not change unless Angular is reloaded. This assures that
      # jQuery will not loose the unique id assigned to the datepicker field
      scope.datePickerId = (condition)->
        "condition-#{condition.datepickerId}-date-picker"

      scope.assignments = UnlockConditionService.assignments

      scope.assignmentStates = (assignmentId)->
        return ["Submitted", "Feedback Read"] if !assignmentId
        assignment = _.find(UnlockConditionService.assignments, {id: assignmentId.toString()})
        if assignment && assignment.pass_fail
          ["Submitted", "Feedback Read", "Passed"]
        else
          ["Submitted", "Feedback Read", "Grade Earned"]

      scope.badges = UnlockConditionService.badges

      scope.assignmentTypes = UnlockConditionService.assignmentTypes
      scope.learningObjectives = UnlockConditionService.learningObjectives
      scope.assignmentTypeStates = ["Assignments Completed", "Minimum Points Earned"]
      scope.learningObjectiveStates = ["Completed"]
      scope.conditionTypes = UnlockConditionService.conditionTypes
  }
]

