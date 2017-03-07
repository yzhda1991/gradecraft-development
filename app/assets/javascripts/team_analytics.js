if ($('#leaderboardBarChart').length) {
  var teamScores = JSON.parse($('#leaderboardBarChart').attr('data-scores')).scores;

  var xValues = [];
  var yValues = [];

  teamScores.forEach(function(score) {
    var xValue = score.name;
    xValues.push(xValue);

    var yValue = score.data;
    yValues.push(yValue);
  });

  var data = [
    {
      x: xValues,
      y: yValues,
      type: 'bar',
      marker: {
        size: 4,
        color: 'rgba(31, 119, 180, 0.5)',
        line: {
          color: 'rgba(31, 119, 180, 1)',
          width: 2
        }
      }
    }
  ];

  var layout = {
    showlegend: false,
    hovermode: !1,
    margin: {
      l: 80,
      r: 40,
      b: 60,
      t: 4,
      pad: 8
    },
    xaxis: {
      fixedrange: true,
      title: 'Team'
    },
    yaxis: {
      fixedrange: true,
      title: 'Score',
      tickformat: ',d'
    }
  };

  // eslint-disable-next-line no-undef
  Plotly.newPlot('leaderboardBarChart', data, layout, {displayModeBar: false});
}
