# box plot for course grade distribution
@gradecraft.directive 'weeklyStatsAnalytics', ['$q', 'AnalyticsService', ($q, AnalyticsService) ->
    weeklyStatsCtrl = [()->
      vmWeeklyStats = this
      vmWeeklyStats.loading = true

      services().then(()->
        vmWeeklyStats.loading = false
      )
    ]

    services = ()->
      promises = [
        #AnalyticsService.getCourseAnalytics()
      ]
      return $q.all(promises)

    {
      bindToController: true,
      controller: weeklyStatsCtrl,
      controllerAs: 'vmWeeklyStats',
      templateUrl: 'analytics/weekly_stats.html'
    }

]
