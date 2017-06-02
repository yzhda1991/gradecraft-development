# box plot for score distribution
# includes an users's score if supplied

@gradecraft.directive 'boxPlotScores', [() ->
    plotGraph = (data, graphId)=>
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

      Plotly.newPlot(graphId, data, layout, {displayModeBar: false})

    {
      scope: {
        data: "=",
        graphId: "@"
      },
      link: (scope, el, attrs)->
        plotGraph(scope.data, scope.graphId)
    }

]
