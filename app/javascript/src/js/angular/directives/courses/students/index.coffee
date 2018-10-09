@gradecraft.directive "coursesStudentsIndex", ["CourseService", "StudentService", "SortableService", "TeamService", "$filter",
  (CourseService, StudentService, SortableService, TeamService, $filter) ->
    CoursesStudentsIndexCtrl = [() ->
      vm = this
      vm.loadingCourse = true
      vm.loadingStudents = true
      vm.searchCriteria = undefined
      vm.sortable = SortableService

      vm.team = StudentService.team
      vm.course = CourseService.course
      vm.filteredStudents = StudentService.students
      vm.studentEarnedBadges = StudentService.earnedBadges
      vm.batchLoadingProgress = StudentService.loadingProgress

      vm.termFor = (term) -> StudentService.termFor(term)
      vm.earnedBadgesForStudent = (studentId) -> StudentService.earnedBadgesForStudent(studentId)

      vm.flagStudent = (student) -> StudentService.flag(_findStudent(student.id)).then(() -> vm.updateFiltered())
      vm.activateUser = (student) -> StudentService.activate(_findStudent(student.id)).then(() -> vm.updateFiltered())
      vm.toggleActivation = (student) -> StudentService.toggleActivation(student.course_membership_id, _findStudent(student.id)).then(() -> vm.updateFiltered())
      vm.deleteFromCourse = (student) -> StudentService.deleteFromCourse(student.course_membership_id, _findStudent(student.id)).then(() -> vm.updateFiltered())

      vm.courseHasTeams = () -> vm.course().has_teams
      vm.courseHasBadges = () -> vm.course().has_badges
      vm.showRole = () -> vm.courseHasTeams() && vm.course().has_team_roles
      vm.displayPseudonyms = () -> vm.course().has_in_team_leaderboards || vm.course().has_character_names

      vm.showActivateAccount = (student) -> vm.isAdmin && !student.activated

      vm.showResendActivationEmail = (student) ->
        vm.isStaff && !student.activated && !vm.isUmichEnvironment

      vm.updateFiltered = (recalculate=true) ->
        vm.filteredStudents = $filter("filter")(StudentService.students, _filterCriteria)
        vm.filteredStudents = $filter("filter")(vm.filteredStudents, { $: vm.searchCriteria }) if vm.searchCriteria?
        StudentService.recalculateRanks(vm.filteredStudents) if recalculate is true

      _initialize(vm)
    ]

    _initialize = (vm) ->
      SortableService.predicate = "rank"
      TeamService.callback(vm.updateFiltered)

      CourseService.getCourse(vm.courseId).then(
        (response) ->
          vm.loadingCourse = false
          StudentService.getBatchedForCourse(vm.courseId).then(() -> vm.loadingStudents = false)
        , (response) ->
          console.error("Failed to load course data")
      )

    # Since we manually trigger an update for the filtered collection based off
    #   of the original collection each time something changes, any updates we
    #   do such as updating activation status will need to happen on the
    #   corresponding original student
    _findStudent = (id) -> _.find(StudentService.students, { id: id })

    # A filter expression to be used for the AngularJS filter
    # Student is returned as part of the collection if they match the specified
    #   team and table filter criteria
    _filterCriteria = (student) ->
      filterCriteria = SortableService.filterCriteria()
      selectedTeamId = TeamService.selectedTeamId()

      filter = if filterCriteria? then filterCriteria(student) else true
      team = if _.isEmpty(selectedTeamId) then true else student.team_id == selectedTeamId
      filter && team

    {
      scope:
        courseId: "@"
        linksVisible: "@"
        isAdmin: "@"
        isStaff: "@"
        isUmichEnvironment: "@"
      bindToController: true
      controller: CoursesStudentsIndexCtrl
      controllerAs: "coursesStudentsIndexCtrl"
      templateUrl: "courses/students/index.html"
    }
]
