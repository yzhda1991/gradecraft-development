// truncate function until plotlyjs handles axis label resizing
function truncateLabel(label, max) {
  return label.length > max ? label.substr(0, max-1) + '…' : label;
}

if ($('#leaderboardBarChart').length) {
  var teamScores = JSON.parse($('#leaderboardBarChart').attr('data-scores'));

  var xValues = [];
  var yValues = [];

  teamScores.forEach(function(score) {
    var xValue = truncateLabel(score.name, 10);
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
    height: 400,
    margin: {
      l: 80,
      r: 40,
      b: 60,
      t: 4,
      pad: 8
    },
    xaxis: {
      fixedrange: true
    },
    yaxis: {
      fixedrange: true,
      title: 'Score',
      tickprefix: '     '
    }
  };

  // eslint-disable-next-line no-undef
  Plotly.newPlot('leaderboardBarChart', data, layout, {displayModeBar: false});
}
