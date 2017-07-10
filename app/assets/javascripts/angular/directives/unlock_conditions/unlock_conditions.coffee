@gradecraft.directive 'unlockConditions', ['$q', 'UnlockConditionService', ($q, UnlockConditionService) ->
  unlockConditionsCtrl = [()->
    vmUnlocks = this

    vmUnlocks.loading = true

    vmUnlocks.conditions = UnlockConditionService.unlockConditions
    vmUnlocks.termFor = (item)->
      UnlockConditionService.termFor(item)

    vmUnlocks.conditionTypes = ["Assignment Type", "Assignment", "Badge", "Earned Point Value"]

    vmUnlocks.conditionsTypeTranslation = (type)->
      switch type
        when  "Earned Point Value" then "Course"
        when "Assignment Type" then "AssignmentType"
        else type

    vmUnlocks.assignments = UnlockConditionService.assignments
    vmUnlocks.assignmentStates = (assignmentId)->
      assignment = _.find(UnlockConditionService.assignments, {id: assignmentId})
      if assignment && assignment.pass_fail
        ["Submitted", "Feedback Read", "Passed"]
      else
        ["Submitted", "Feedback Read", "Grade Earned"]

    vmUnlocks.badges = UnlockConditionService.badges
    #TODO: If condition of Badge, Course, condition.condition_state == "Earned"

    vmUnlocks.assignmentTypes = UnlockConditionService.assignmentTypes
    vmUnlocks.assignmentTypeStates = ["Assignments Completed", "Minimum Points Earned"]

    vmUnlocks.removeCondition = (index)->
      UnlockConditionService.removeCondition(index)
    vmUnlocks.addCondition = ()->
      UnlockConditionService.addCondition()

    services(@conditionId, @conditionType).then(()->
      vmUnlocks.loading = false
    )
  ]

  services = (conditionId, conditionType)->
    promises = [UnlockConditionService.getUnlockConditions(conditionId, conditionType)]
    return $q.all(promises)

  {
    bindToController: true,
    controller: unlockConditionsCtrl,
    controllerAs: 'vmUnlocks',
    restrict: 'EA',
    scope: {
      conditionId: "=",
      conditionType: "@"
      },
    templateUrl: 'unlock_conditions/main.html'
  }
]

