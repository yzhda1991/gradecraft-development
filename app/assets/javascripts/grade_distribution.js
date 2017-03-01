var $gradeDistro = $('#grade_distro');
if ($gradeDistro.length) {
  var dataSet = JSON.parse($gradeDistro.attr('data-scores'));
}
var scores = dataSet.scores;
var userScore = dataSet.user_score[0];

var data = [{
  x: scores,
  type: 'box'
}];

var layout = {
  showlegend: false,
  height: 120,
  hovermode: !1,
  margin: {
    l: 8,
    r: 8,
    b: 40,
    t: 8,
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

function numberWithCommas(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

if ($gradeDistro.hasClass('student-distro')) {
  layout.annotations = [{
    x: userScore,
    y: 0,
    xref: 'x',
    yref: 'y',
    text: numberWithCommas(userScore),
    showarrow: true,
    arrowhead: 2,
    arrowsize: 1,
    arrowwidth: 2,
    ax: 0.5,
    ay: -40
  }]
}

  // eslint-disable-next-line no-undef
  Plotly.newPlot('grade_distro', data, layout, {displayModeBar: false}); 
