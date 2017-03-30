# box plot for assignment grade distribution
# includes an individual's grade if supplied

@gradecraft.directive 'assignmentParticipationAnalytics', ['$q', 'AnalyticsService', ($q, AnalyticsService) ->
    analyticsParticipationCtrl = [()->
      vm = this

      services(vm.assignmentId, vm.studentId).then(()->
        vm.assignment_average = AnalyticsService.assignmentData.assignment_average
        vm.assignment_low_score = AnalyticsService.assignmentData.assignment_low_score
        vm.assignment_high_score = AnalyticsService.assignmentData.assignment_high_score
        plotGraph(AnalyticsService.assignmentData)
      )
    ]

    services = (assignmentId, studentId)->
      promises = [
        AnalyticsService.getAssignmentAnalytics(assignmentId, studentId)
      ]
      return $q.all(promises)

    plotGraph = (data)->
      percentParticipated = data.participation_rate
      percentNotParticipated = 100 - percentParticipated
      participationData = [{
        values: [percentParticipated, percentNotParticipated],
        labels: ['Students Participated, Not Participated'],
        type: 'pie',
        hole: .6,
        text: [percentParticipated + '%', null],
        textinfo: 'text',
        marker: {
          colors: ['rgba(31, 119, 180, 0.5)', 'rgba(222,227,229, 0.5)' ],
          line: {
            color: 'rgba(31, 119, 180, 1)',
            width: 2
          }
        }
      }]

      pieLayout = {
        showlegend: false,
        height: 220,
        width: 220,
        hovermode: !1,
        margin: {
          l: 8,
          r: 8,
          b: 40,
          t: 4,
          pad: 8
        },
        annotations: [{
          font: {
            size: 16
          },
          showarrow: false,
          text: 'Students<br> Participated',
          x: 0.5,
          y: 0.5
        }]
      }

      Plotly.newPlot('assignment-participation-graph', participationData, pieLayout, {displayModeBar: false})


    {
      bindToController: true,
      controller: analyticsParticipationCtrl,
      controllerAs: 'vm',
      scope: {
         assignmentId: "=",
         studentId: "=",
        }
      templateUrl: 'analytics/assignment_participation.html'
    }
]


