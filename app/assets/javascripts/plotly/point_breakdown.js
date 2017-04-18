var $pointBreakdownChart = $('#point-breakdown-chart');
if ($pointBreakdownChart.length) {
  var assignmentTypeTotals = JSON.parse($('#point-breakdown-chart').attr('data-pointbreakdown'));
  var assignmentTypeScores = assignmentTypeTotals.points_by_assignment_type;
  assignmentTypeScores.push(assignmentTypeTotals.earned_badge_points);
  var xMaxValue = assignmentTypeTotals.course_potential_for_student;

  var traces = [];
  var colors = [
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
  ];

  assignmentTypeScores.forEach(function(assignmentType, index) {
    var points = assignmentType.points;
    var name = assignmentType.name;
    var tooltip = name + '<br>' + points.toLocaleString() + ' points';
    var colorsCount = colors.length;

    var trace = {
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
    };
    traces.push(trace);
  });

  var data = traces;

  var layout = {
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
  };

    // eslint-disable-next-line no-undef
    Plotly.newPlot('point-breakdown-chart', data, layout, {displayModeBar: false});

    document.getElementById('point-breakdown-chart').on('plotly_hover', function(data) {
      var barColor = data.points[0].fullData.marker.color;
      $('.hovertext path').attr('data-color', barColor);
    });
}
