# box plot for course grade distribution
# includes an individual's grade if supplied

@gradecraft.directive 'courseDistributionAnalytics', ['$q', '$window', '$rootElement', 'AnalyticsService', 'DebounceQueue', ($q, $window, $rootElement, AnalyticsService, DebounceQueue) ->
    analyticsDistCtrl = [()->
      vm = this

      initializeGraph = () ->
        plotGraph(AnalyticsService.courseData)
        angular.element($window).on 'resize', ->
          DebounceQueue.addEvent(
            "graphs", 'courseDistributionAnalytics', refreshGraph, [], 250
          )

      services().then(()->
        vm.userScore = AnalyticsService.courseData.user_score
        vm.courseAverage = AnalyticsService.courseData.course_average
        vm.courseLowScore = AnalyticsService.courseData.course_low_score
        vm.courseHighScore = AnalyticsService.courseData.course_high_score
        initializeGraph()
      )
    ]

    services = ()->
      promises = [
        AnalyticsService.getCourseAnalytics()
      ]
      return $q.all(promises)

    plotGraph = (data)=>
      scores = data.scores
      userScore = data.user_score

      data = [{
        x: scores,
        type: 'box'
      }];

      layout = {
        showlegend: false,
        height: 100,
        autosize: true,
        hovermode: !1,
        margin: {
          l: 8,
          r: 8,
          b: 40,
          t: 4,
          pad: 8
        },
        xaxis: {
          fixedrange: true
        },
        yaxis: {
          fixedrange: true,
          showticklabels: false
        },
        marker: {
          size: 4
        }
      }

      if userScore
        layout.height = 130;
        layout.annotations = [{
          x: userScore,
          y: 0,
          xref: 'x',
          yref: 'y',
          text: 'Your Score:<br>' + userScore.toLocaleString(),
          showarrow: true,
          arrowhead: 2,
          arrowsize: 1,
          arrowwidth: 2,
          ax: 0,
          ay: -40
        }]

      Plotly.newPlot('course-distribution-graph', data, layout, {displayModeBar: false})

    refreshGraph = ()=>
      Plotly.Plots.resize document.getElementById('course-distribution-graph')

    {
      bindToController: true,
      controller: analyticsDistCtrl,
      controllerAs: 'vm',
      templateUrl: 'analytics/course_distribution.html'
    }

]
