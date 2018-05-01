@gradecraft.directive "coursesStudentsIndex", ["CourseService", "StudentService", "SortableService", "TeamService", "$q", (CourseService, StudentService, SortableService, TeamService, $q) ->
  CoursesStudentsIndexCtrl = [() ->
    vm = this
    vm.loading = true
    vm.sortable = SortableService

    vm.course = CourseService.course

    vm.team = StudentService.team
    vm.students = StudentService.students
    vm.studentEarnedBadges = StudentService.earnedBadges

    vm.flagStudent = (student) -> StudentService.flag(student)
    vm.activateUser = (student) -> StudentService.activate(student)
    vm.toggleActivation = (student) -> StudentService.toggleActivation(student.course_membership_id, student)
    vm.deleteFromCourse = (student) -> StudentService.deleteFromCourse(student.course_membership_id, student)

    vm.earnedBadgesForStudent = (studentId) -> StudentService.earnedBadgesForStudent(studentId)
    vm.termFor = (term) -> StudentService.termFor(term)

    vm.courseHasTeams = () -> vm.course().has_teams
    vm.courseHasBadges = () -> vm.course().has_badges

    vm.displayPseudonyms = () -> vm.course().has_in_team_leaderboards || vm.course().has_character_names
    vm.showRole = () -> vm.courseHasTeams() && vm.course().has_team_roles

    vm.showActivateAccount = (student) -> vm.isAdmin && !student.activated

    vm.showResendActivationEmail = (student) ->
      vm.isStaff && !student.activated && !vm.isUmichEnvironment

    vm.filterCriteria = (student) ->
      filterCriteria = SortableService.filterCriteria()
      selectedTeamId = TeamService.selectedTeamId()

      return true if not filterCriteria? and not selectedTeamId?

      if filterCriteria? and selectedTeamId?
        filterCriteria(student) && student.team_id == selectedTeamId
      else if filterCriteria?
        filterCriteria(student)
      else
        student.team_id == selectedTeamId

    services(@courseId).then(() -> vm.loading = false)
  ]

  services = (courseId) ->
    promises = [
      CourseService.getCourse(courseId),
      StudentService.getForCourse(courseId)
    ]
    $q.all(promises)

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
