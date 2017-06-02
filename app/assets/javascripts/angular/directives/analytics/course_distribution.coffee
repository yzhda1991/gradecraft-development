# box plot for course grade distribution
# includes an individual's grade if supplied

@gradecraft.directive 'courseDistributionAnalytics', ['$q', '$window', '$rootElement', 'AnalyticsService', 'DebounceQueue', ($q, $window, $rootElement, AnalyticsService, DebounceQueue) ->
    analyticsDistCtrl = [()->
      vm = this
      vm.loading = true

      services().then(()->
        vm.userScore = AnalyticsService.courseData.user_score
        vm.courseAverage = AnalyticsService.courseData.course_average
        vm.courseLowScore = AnalyticsService.courseData.course_low_score
        vm.courseHighScore = AnalyticsService.courseData.course_high_score
        vm.data = AnalyticsService.courseData
        vm.loading = false
        angular.element($window).on 'resize', ->
          DebounceQueue.addEvent(
            "graphs", 'courseDistributionAnalytics', refreshGraph, [], 250
          )
      )
    ]

    services = ()->
      promises = [
        AnalyticsService.getCourseAnalytics()
      ]
      return $q.all(promises)

    refreshGraph = ()=>
      Plotly.Plots.resize document.getElementById('course-distribution-graph')

    {
      bindToController: true,
      controller: analyticsDistCtrl,
      controllerAs: 'vm',
      templateUrl: 'analytics/course_distribution.html'
    }

]
