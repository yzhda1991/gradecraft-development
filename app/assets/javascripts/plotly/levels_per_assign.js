if ($('#levels-per-assignment').length) {
  var assignmentGrades = JSON.parse($('#levels-per-assignment').attr('data-levels'));
  var studentGrade = JSON.parse($('#levels-per-assignment').attr('data-user-scores'));
  var grades = assignmentGrades.scores;

  var xValues = [];
  var yValues = [];
  var colors = [];
  var outlineColors = [];
  var yStudentMarker;

  grades.forEach(function(grade) {
    var xValue = grade.name;
    xValues.push(xValue);

    var yValue = grade.data;
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

  if ($('#levels-per-assignment').hasClass('student-distro')) {
      layout.height = 230;
      if (studentGrade) {
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
    }

  // eslint-disable-next-line no-undef
  Plotly.newPlot('levels-per-assignment', data, layout, {displayModeBar: false});
}
