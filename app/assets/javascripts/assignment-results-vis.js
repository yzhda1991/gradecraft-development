var $assignmentDistro = $('#grades_per_assign');
if ($assignmentDistro.length) {
  var dataSet = JSON.parse($assignmentDistro.attr('data-scores'));
  var scores = dataSet.scores;
  var userScore = dataSet.user_score;

  var data = [{
    x: scores,
    type: 'box'
  }];

  var layout = {
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
  };

  if ($assignmentDistro.hasClass('student-distro')) {
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
  }

    // eslint-disable-next-line no-undef
    Plotly.newPlot('grades_per_assign', data, layout, {displayModeBar: false});
}

var $numberComplete = $('#numberComplete');
if ($numberComplete.length) {
  var percentParticipated = JSON.parse($numberComplete.attr('data-percent'));
  var percentNotParticipated = 100 - percentParticipated;
  var participationData = [{
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
  }];

  var pieLayout = {
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
  };

  Plotly.newPlot('numberComplete', participationData, pieLayout, {displayModeBar: false});
}
