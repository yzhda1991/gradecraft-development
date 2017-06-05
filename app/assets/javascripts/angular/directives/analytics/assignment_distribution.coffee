# box plot for assignment grade distribution
@gradecraft.directive 'assignmentDistributionAnalytics', ['$q', '$window', 'AnalyticsService', 'DebounceQueue', ($q, $window, AnalyticsService, DebounceQueue) ->
    analyticsDistCtrl = [()->
      vm = this
      vm.loading = true

      initializeGraph = () ->
        vm.loading = false
        # plotGraph(AnalyticsService.assignmentData)
        angular.element($window).on 'resize', ->
          DebounceQueue.addEvent(
            "graphs", 'assignmentDistributionAnalytics', refreshGraph, [], 250
          )

      services(vm.assignmentId, vm.studentId).then(()->
        vm.assignmentAverage = AnalyticsService.assignmentData.assignment_average
        vm.assignmentLowScore = AnalyticsService.assignmentData.assignment_low_score
        vm.assignmentHighScore = AnalyticsService.assignmentData.assignment_high_score
        vm.data = AnalyticsService.assignmentData
        # plot graph when tab is activated for chart usage in jquery ui tabs
        if angular.element('.analytics-tab-panel').length > 0
          angular.element('#tabs').on 'tabsactivate', ->
            if event.currentTarget.classList.contains('class-analytics-tab')
              initializeGraph()
        else
          initializeGraph()
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
