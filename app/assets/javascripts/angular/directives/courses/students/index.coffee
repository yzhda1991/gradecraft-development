@gradecraft.directive "coursesStudentsIndex", ["CourseService", "StudentService", "SortableService", "TeamService", "$q",
  (CourseService, StudentService, SortableService, TeamService, $q) ->
    CoursesStudentsIndexCtrl = [() ->
      vm = this
      vm.loading = true
      vm.searchCriteria = undefined
      vm.sortable = SortableService

      vm.team = StudentService.team
      vm.course = CourseService.course
      vm.students = StudentService.students
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

      vm.filterCriteria = (student) ->
        filterCriteria = SortableService.filterCriteria()
        selectedTeamId = TeamService.selectedTeamId()

        filter = if filterCriteria? then filterCriteria(student) else true
        team = if selectedTeamId? then student.team_id == selectedTeamId else true
        filter && team

      SortableService.reverse = true
      SortableService.predicate = "score"

      CourseService.getCourse(@courseId).then(
        (response) ->
          vm.loading = false
          StudentService.getBatchedForCourse(vm.courseId)
        , (response) ->
          console.error("Failed to load course data")
      )
    ]

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
