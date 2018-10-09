# bar graph for assignment grades earned
# includes an individual's grade if supplied

@gradecraft.directive 'assignmentScoresEarnedAnalytics', ['$q', '$window', 'AnalyticsService', 'DebounceQueue', ($q, $window, AnalyticsService, DebounceQueue) ->
    analyticsScoresEarnedCtrl = [()->
      vm = this

      initializeGraph = () ->
        plotGraph(AnalyticsService.assignmentData)
        angular.element($window).on 'resize', ->
          DebounceQueue.addEvent(
            "graphs", 'assignmentScoresEarnedAnalytics', refreshGraph, [], 250
          )

      services(vm.assignmentId, vm.studentId).then(()->
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

    plotGraph = (data)->
      studentGrade = data.user_score
      scoreFrequency = data.assignment_score_frequency

      xValues = []
      yValues = []
      colors = []
      outlineColors = []
      marker = this

      scoreFrequency.forEach((scoreLevel)->
        xValue = scoreLevel.score
        xValues.push(xValue)
      
        yValue = scoreLevel.frequency
        yValues.push(yValue)
      
        if (xValue == studentGrade)
          marker.yStudentMarker = yValue
          colors.push('rgba(109, 214, 119, 0.5)')
          outlineColors.push('rgba(109, 214, 119, 1)')
        else
          colors.push('rgba(31, 119, 180, 0.5)')
          outlineColors.push('rgba(31, 119, 180, 1)')
      )

      data = [
        {
          x: xValues,
          y: yValues,
          type: 'bar',
          marker: {
            size: 4,
            color: colors,
            line: {
              color: outlineColors,
              width: 2
            }
          }
        }
      ]

      layout = {
        showlegend: false,
        autosize: true,
        hovermode: !1,
        height: 240,
        margin: {
          l: 50,
          r: 20,
          b: 60,
          t: 4,
          pad: 8
        },
        xaxis: {
          fixedrange: true,
          title: 'Score'
        },
        yaxis: {
          fixedrange: true,
          title: '# of Students',
          tickformat: ',d'
        }
      }

      if studentGrade
        layout.height = 230
        layout.annotations = [{
          x: studentGrade,
          y: marker.yStudentMarker,
          xref: 'x',
          yref: 'y',
          yanchor: 'bottom',
          xanchor: 'center',
          text: 'Your Score',
          showarrow: true,
          arrowhead: 2,
          arrowsize: 1,
          arrowwidth: 2,
          ax: 0,
          ay: -20
        }]

      Plotly.newPlot('assignment-scores-earned-graph', data, layout, {displayModeBar: false})

    refreshGraph = ()=>
      Plotly.Plots.resize document.getElementById('assignment-scores-earned-graph')

    {
      bindToController: true,
      controller: analyticsScoresEarnedCtrl,
      controllerAs: 'vm',
      scope: {
         assignmentId: "=",
         studentId: "=",
        }
      templateUrl: 'analytics/assignment_scores_earned.html'
    }
]
