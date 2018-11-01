# graph of student's points, broken down by assignment type
# Used on student dashboard

gradecraft.directive 'pointsBreakdownAnalytics', ['$q', '$window', 'AnalyticsService', 'DebounceQueue', ($q, $window, AnalyticsService, DebounceQueue) ->
    pointsBreakdownCtrl = [()->
      vmPtsBreakdown = this
      services(vmPtsBreakdown.studentId).then(()->
        plotGraph(AnalyticsService.studentData)
      )

      angular.element($window).on 'resize', ->
        DebounceQueue.addEvent(
          "graphs", 'pointsBreakdownAnalytics', refreshGraph, [], 250
        )
    ]

    services = (studentId)->
      promises = [
        AnalyticsService.getStudentAnalytics(studentId)
      ]
      return $q.all(promises)

    plotGraph = (data)->
      assignmentTypeScores = data.points_by_assignment_type
      assignmentTypeScores.push(data.earned_badge_points)
      xMaxValue = data.course_potential_points_for_student


      traces = []
      colors = [
        '#00274F',
        '#215089',
        '#2E70BE',
        '#B9D6F2',
        '#8ED0FF',
        '#490454',
        '#8F27A1',
        '#9FE88D',
        '#6DD677',
        '#25B256',
        '#D1495B',
        '#FEB130',
        '#FFCF06'
      ]

      assignmentTypeScores.forEach((assignmentType, index)=>
        points = assignmentType.points
        name = assignmentType.name
        tooltip = name + '<br>' + points.toLocaleString() + ' points'
        colorsCount = colors.length

        trace = {
          x: [points],
          name: name,
          orientation: 'h',
          marker: {
            color: colors[index % colorsCount],
            size: 1
          },
          type: 'bar',
          text: [tooltip],
          hoverinfo: 'text'
        }
        traces.push(trace)
      )

      data = traces

      layout = {
        showlegend: false,
        hovermode: 'closest',
        height: 100,
        barmode: 'stack',
        margin: {
          l: 8,
          r: 8,
          b: 40,
          t: 8,
          pad: 8
        },
        xaxis: {
          fixedrange: true,
          range: [0, xMaxValue]
        },
        yaxis: {
          autorange: true,
          showgrid: false,
          zeroline: false,
          showline: false,
          autotick: true,
          ticks: '',
          showticklabels: false,
          fixedrange: true
        }
      }

      Plotly.newPlot('point-breakdown-chart', data, layout, {displayModeBar: false})

      document.getElementById('point-breakdown-chart').on('plotly_hover', (data)=>
        barColor = data.points[0].fullData.marker.color
        $('.hovertext path').attr('data-color', barColor)
      )

    refreshGraph = ()=>
      Plotly.Plots.resize document.getElementById('point-breakdown-chart')

    {
      bindToController: true,
      controller: pointsBreakdownCtrl,
      controllerAs: 'vmPtsBreakdown',
      scope: {
        studentId: "="
      }
      templateUrl: 'analytics/points_breakdown.html'
    }
]
