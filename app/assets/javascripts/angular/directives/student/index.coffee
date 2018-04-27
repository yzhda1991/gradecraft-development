@gradecraft.directive "coursesStudentsIndex", ["CourseService", "StudentService", "$q", (CourseService, StudentService, $q) ->
  CoursesStudentsIndexCtrl = [() ->
    vm = this
    vm.loading = true

    vm.course = CourseService.course
    vm.students = StudentService.students

    vm.termFor = (term) -> StudentService.termFor(term)

    vm.courseHasTeams = () -> vm.course().has_teams
    vm.courseHasBadges = () -> vm.course().has_badges

    vm.displayPseudonyms = () -> vm.course().has_in_team_leaderboards || vm.course().has_character_names
    vm.showRole = () -> vm.courseHasTeams() && vm.course().has_team_roles

    vm.showActivateAccount = (student) -> 
      vm.isAdmin && !student.activated

    vm.showResendActivationEmail = (student) ->
      vm.isStaff && !student.activated && !vm.isUmichEnvironment

    vm.flagStudent = (student) -> StudentService.flagStudent(student.flag_user_path)

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
