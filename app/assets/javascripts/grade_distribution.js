var $gradeDistro = $('#grade_distro');
if ($gradeDistro.length) {
  var dataSet = JSON.parse($gradeDistro.attr('data-scores'));
}
var scores = dataSet.scores;
var userScore = dataSet.user_score[0];

var trace1 = {
  x: scores,
  type: 'box'
};

var data = [trace1];

var layout = {
  showlegend: false,
  height: 160,
  margin: {
    l: 8,
    r: 8,
    b: 40,
    t: 8,
    pad: 8
  },
  yaxis: {
    showticklabels: false
  },
  marker: {
    size: 4
  }
};

if ($gradeDistro.hasClass('student-distro')) {
    layout.annotations = [
      {
        x: userScore,
        y: 0,
        xref: 'x',
        yref: 'y',
        text: userScore,
        showarrow: true,
        arrowhead: 2,
        arrowsize: 1,
        arrowwidth: 2,
        ax: 0.5,
        ay: -50
      }
    ]
  }

  Plotly.newPlot('grade_distro', data, layout, {displayModeBar: false});
