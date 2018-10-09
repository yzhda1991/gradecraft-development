# box plot for course grade distribution
@gradecraft.directive 'weeklyStatsAnalytics', ['AnalyticsService', (AnalyticsService) ->
    weeklyStatsCtrl = [()->
      vmWeeklyStats = this
      vmWeeklyStats.loading = true

      AnalyticsService.getWeeklyAnalytics(vmWeeklyStats.studentId).then(()->
        vmWeeklyStats.loading = false
      )
    ]

    {
      bindToController: true,
      controller: weeklyStatsCtrl,
      controllerAs: 'vmWeeklyStats',
      scope: {
        studentId: "="
      }
      link: (scope, el, attr)->
        scope.data = AnalyticsService.weeklyData
        scope.termFor = AnalyticsService.termFor

        scope.hasStudentData = ()->
          AnalyticsService.weeklyData.student_data

        scope.hasFacultyData = ()->
          AnalyticsService.weeklyData.faculty_data

        scope.hasOnlyFacultyData = ()->
          scope.hasFacultyData() && !scope.hasStudentData()

        scope.hasStudentEarnedPoints = ()->
          scope.hasStudentData() && scope.data.student_data.points_this_week > 0

        scope.hasStudentEarnedGrades = ()->
          scope.hasStudentData() && scope.data.student_data.grades_this_week.length

        scope.hasStudentEarnedBadges = ()->
          scope.hasStudentData() && scope.data.student_data.badges_this_week.length

        scope.hasNoStudentEarnings = ()->
          !scope.hasStudentEarnedPoints() &&
          !scope.hasStudentEarnedGrades() &&
          !scope.hasStudentEarnedBadges()

        scope.hasClassSubmissions = ()->
          scope.hasFacultyData() && scope.data.faculty_data.submissions_this_week.length

        scope.hasClassEarnedBadges = ()->
          scope.hasFacultyData() && scope.data.faculty_data.badges_this_week.length

        scope.hasNoClassEarnings = ()->
          !scope.hasClassSubmissions() &&
          !scope.hasClassEarnedBadges()

        scope.passFailGrade = (grade)->
          grade.pass_fail_status

      templateUrl: 'analytics/weekly_stats.html'
    }
]
