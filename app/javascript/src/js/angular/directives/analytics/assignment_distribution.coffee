# box plot for assignment grade distribution
main.gradecraft().directive 'assignmentDistributionAnalytics', ['$q', '$window', 'AnalyticsService', 'DebounceQueue', ($q, $window, AnalyticsService, DebounceQueue) ->
    analyticsDistCtrl = [()->
      vm = this
      vm.loading = true

      services(vm.assignmentId, vm.studentId).then(()->
        vm.assignmentAverage = AnalyticsService.assignmentData.assignment_average
        vm.assignmentLowScore = AnalyticsService.assignmentData.assignment_low_score
        vm.assignmentHighScore = AnalyticsService.assignmentData.assignment_high_score
        vm.data = AnalyticsService.assignmentData
        vm.loading = false

        angular.element($window).on 'resize', ->
          refreshGraph()

        # plot graph when tab is activated for chart usage in jquery ui tabs
        if angular.element('.analytics-tab-panel').length > 0
          angular.element('#tabs').on 'tabsactivate', ->
            if event.currentTarget.classList.contains('class-analytics-tab')
              refreshGraph()
      )
    ]

    services = (assignmentId, studentId)->
      promises = [
        AnalyticsService.getAssignmentAnalytics(assignmentId, studentId)
      ]
      return $q.all(promises)

    refreshGraph = ()=>
      Plotly.Plots.resize document.getElementById('assignment-distribution-graph')

    {
      bindToController: true,
      controller: analyticsDistCtrl,
      controllerAs: 'vm',
      scope: {
         assignmentId: "=",
         studentId: "=",
        }
      templateUrl: 'analytics/assignment_distribution.html'
    }

]
