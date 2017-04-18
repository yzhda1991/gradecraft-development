# box plot for assignment grade distribution
# includes an individual's grade if supplied

@gradecraft.directive 'assignmentDistributionAnalytics', ['$q', 'AnalyticsService', '$window', ($q, AnalyticsService, $window) ->
    analyticsDistCtrl = [()->
      vm = this

      services(vm.assignmentId, vm.studentId).then(()->
        vm.assignment_average = AnalyticsService.assignmentData.assignment_average
        vm.assignment_low_score = AnalyticsService.assignmentData.assignment_low_score
        vm.assignment_high_score = AnalyticsService.assignmentData.assignment_high_score
        plotGraph(AnalyticsService.assignmentData, vm.studentDistro)
      )
    ]

    services = (assignmentId, studentId)->
      promises = [
        AnalyticsService.getAssignmentAnalytics(assignmentId, studentId)
      ]
      return $q.all(promises)

    plotGraph = (data, studentDistro)=>
      scores = data.scores
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

      plotAssignmentDistro = ->
        Plotly.newPlot('assignment-distribution-graph', data, layout, {displayModeBar: false})

      plotAssignmentDistro()

      resizeTimer = undefined
      angular.element($window).on 'resize', ->
        clearTimeout resizeTimer
        resizeTimer = setTimeout(plotAssignmentDistro, 250)

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
