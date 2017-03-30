var $assignmentLevelsAnalytics = $('#assignment-levels-analytics');
if ($assignmentLevelsAnalytics.length) {
  var assignment_id = $assignmentLevelsAnalytics.attr('data-assignment-id');
  var student_id = $assignmentLevelsAnalytics.attr('data-student-id');
  $.get( "/api/assignments/" + assignment_id + "/analytics?student_id=" + student_id, function( data ) {
    plotAssignmentLevelsAnalytics(data);
  });
}

var plotAssignmentLevelsAnalytics = function(data){
  var studentGrade = data.user_score;
  var scoreFrequency = data.assignment_score_frequency;

  var xValues = [];
  var yValues = [];
  var colors = [];
  var outlineColors = [];
  var yStudentMarker;

  scoreFrequency.forEach(function(scoreLevel) {
    var xValue = scoreLevel.score;
    xValues.push(xValue);

    var yValue = scoreLevel.frequency;
    yValues.push(yValue);

    if (xValue === studentGrade) {
      yStudentMarker = yValue;
      colors.push('rgba(109, 214, 119, 0.5)');
      outlineColors.push('rgba(109, 214, 119, 1)');
    } else {
      colors.push('rgba(31, 119, 180, 0.5)');
      outlineColors.push('rgba(31, 119, 180, 1)');
    }
  });

  var data = [
    {
      x: xValues,
      y: yValues,
      type: 'bar',
      marker: {
        size: 4,
        color: colors,
        line: {
          color: outlineColors,
          width: 2
        }
      }
    }
  ];

  var layout = {
    showlegend: false,
    hovermode: !1,
    height: 240,
    margin: {
      l: 50,
      r: 20,
      b: 60,
      t: 4,
      pad: 8
    },
    xaxis: {
      fixedrange: true,
      title: 'Score'
    },
    yaxis: {
      fixedrange: true,
      title: '# of Students',
      tickformat: ',d'
    }
  };

  if (studentGrade) {
    layout.height = 230;
    layout.annotations = [{
      x: studentGrade,
      y: yStudentMarker,
      xref: 'x',
      yref: 'y',
      yanchor: 'bottom',
      xanchor: 'center',
      text: 'Your Score',
      showarrow: true,
      arrowhead: 2,
      arrowsize: 1,
      arrowwidth: 2,
      ax: 0,
      ay: -20
    }]
  }

  // eslint-disable-next-line no-undef
  Plotly.newPlot('assignment-levels-analytics', data, layout, {displayModeBar: false});
}
