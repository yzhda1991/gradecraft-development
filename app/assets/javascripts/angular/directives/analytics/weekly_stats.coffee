# box plot for course grade distribution
@gradecraft.directive 'weeklyStatsAnalytics', ['$q', 'AnalyticsService', ($q, AnalyticsService) ->
    weeklyStatsCtrl = [()->
      vmWeeklyStats = this
      vmWeeklyStats.loading = true

      services(vmWeeklyStats.studentId).then(()->
        vmWeeklyStats.loading = false
      )
    ]

    services = (studentId)->
      promises = [
        AnalyticsService.getWeeklyAnalytics(studentId)
      ]
      return $q.all(promises)

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

      templateUrl: 'analytics/weekly_stats.html'
    }
]
