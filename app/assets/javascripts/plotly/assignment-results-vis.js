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
