# box plot for assignment grade distribution
# includes an individuals grade if supplied

@gradecraft.directive 'assignmentDistributionAnalytics', ['$q', 'AnalyticsService', ($q, AnalyticsService) ->
    analyticsDistCtrl = [()->
      vm = this
      services(vm.assignmentId, vm.studentId).then(()->
        plotGraph(AnalyticsService.assignmentData, vm.studentDistro)
      )
    ]

    services = (assignmentId, studentId)->
      promises = [
        AnalyticsService.getAssignmentAnalytics(assignmentId, studentId)
      ]
      return $q.all(promises)

    plotGraph = (data, studentDistro)=>
      scores = data.data_scores
      userScore = data.user_score

      data = [{
        x: scores,
        type: 'box'
      }];

      layout = {
        showlegend: false,
        height: 100,
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

      if studentDistro
        layout.height = 130;
        if userScore
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

      Plotly.newPlot('assignment-distribution-graph', data, layout, {displayModeBar: false})

    {
      bindToController: true,
      controller: analyticsDistCtrl,
      controllerAs: 'vm',
      scope: {
         assignmentId: "=",
         studentId: "=",
         # What does this mean, exactly?
         studentDistro: "="
        }
    }
]


