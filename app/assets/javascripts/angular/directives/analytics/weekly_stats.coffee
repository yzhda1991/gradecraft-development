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
      templateUrl: 'analytics/weekly_stats.html'
    }
]
