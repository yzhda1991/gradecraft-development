@gradecraft.directive "learningObjectivesShow", ["LearningObjectivesService", "CourseService", "$q", (LearningObjectivesService, CourseService, $q) ->
  LearningObjectivesShowCtrl = [() ->
    vm = this
    vm.loading = true
    vm.students = CourseService.students
    vm.objective = LearningObjectivesService.objective
    vm.linkedAssignments = LearningObjectivesService.linkedAssignments

    vm.observedOutcomes = (studentId) ->
      co = vm.cumulativeOutcomeFor(studentId)
      return unless co?
      oo = vm.observedOutcomesFor(co.id)

    vm.observedOutcomesFor = (cumulativeId) ->
      LearningObjectivesService.observedOutcomesFor(cumulativeId)

    vm.cumulativeOutcomeFor = (studentId) ->
      _.find(LearningObjectivesService.cumulativeOutcomes, { user_id: studentId })

    vm.gradePath = (observedOutcomeId) ->
      "/grades/#{observedOutcomeId}"

    services(@objectiveId, @studentId).then(() -> vm.loading = false)
  ]

  services = (objectiveId, studentId)->
    promises = [
      LearningObjectivesService.getObjective(objectiveId, true),
      LearningObjectivesService.getOutcomesForObjective(objectiveId, studentId),
      CourseService.getStudents()
    ]
    $q.all(promises)

  {
    scope:
      studentId: "@"
      objectiveId: "@"
    bindToController: true
    controller: LearningObjectivesShowCtrl
    controllerAs: "loShowCtrl"
    templateUrl: "learning_objectives/objectives/show.html"
  }
]
