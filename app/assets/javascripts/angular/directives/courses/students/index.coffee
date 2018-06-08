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
      vm.studentEarnedBadges = StudentService.earnedBadges
      vm.batchLoadingProgress = StudentService.loadingProgress

      vm.termFor = (term) -> StudentService.termFor(term)
      vm.flagStudent = (student) -> StudentService.flag(student)
      vm.activateUser = (student) -> StudentService.activate(student)
      vm.toggleActivation = (student) -> StudentService.toggleActivation(student.course_membership_id, student)
      vm.deleteFromCourse = (student) -> StudentService.deleteFromCourse(student.course_membership_id, student)
      vm.earnedBadgesForStudent = (studentId) -> StudentService.earnedBadgesForStudent(studentId)

      vm.courseHasTeams = () -> vm.course().has_teams
      vm.courseHasBadges = () -> vm.course().has_badges

      vm.showRole = () -> vm.courseHasTeams() && vm.course().has_team_roles
      vm.displayPseudonyms = () -> vm.course().has_in_team_leaderboards || vm.course().has_character_names

      vm.showActivateAccount = (student) -> vm.isAdmin && !student.activated

      vm.showResendActivationEmail = (student) ->
        vm.isStaff && !student.activated && !vm.isUmichEnvironment

      vm.selectedTeamId = TeamService.selectedTeamId

      vm.filtered = StudentService.students

      vm.updateFiltered = (recalculate=true) ->
        vm.filtered = $filter("filter")(StudentService.students, vm.filterCriteria)
        vm.filtered = $filter("filter")(vm.filtered, { $: vm.searchCriteria }) if vm.searchCriteria?
        StudentService.recalculateRanks(vm.filtered) if recalculate is true

      vm.filterCriteria = (student) ->
        filterCriteria = SortableService.filterCriteria()
        selectedTeamId = TeamService.selectedTeamId()

        filter = if filterCriteria? then filterCriteria(student) else true
        team = if _.isEmpty(selectedTeamId) then true else student.team_id == selectedTeamId
        filter && team

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
