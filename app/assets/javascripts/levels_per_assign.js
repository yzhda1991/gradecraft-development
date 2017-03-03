if ($('#levels_per_assignment').length) {
  var assignmentGrades = JSON.parse($('#levels_per_assignment').attr('data-levels'));
  var studentGrade = JSON.parse($('#grades_per_assign').attr('data-scores')).user_score;
  var grades = assignmentGrades.scores;
  
  var xValues = grades.map(function(grade) {
    return grade.name;
  });
  
  var colors = xValues.map(function(x) {
    if (x === studentGrade) {
      return 'rgba(31, 119, 180, 1)';
    }
    
    return 'rgba(31, 119, 180, 0.5)';
  });
  
  var data = [
    {
      x: xValues,
      y: grades.map(function(grade) {
        return grade.data;
      }),
      type: 'bar',
      marker: {
        size: 4,
        color: colors,
        line: {
          color: 'rgba(31, 119, 180, 1.0)',
          width: 2
        }
      }
    }
  ];

  var layout = {
    showlegend: false,
    hovermode: !1,
    height: 200,
    margin: {
      l: 40,
      r: 8,
      b: 40,
      t: 4,
      pad: 8
    },
    xaxis: {
      fixedrange: true
    },
    yaxis: {
      fixedrange: true
    }
  };
  // eslint-disable-next-line no-undef
  Plotly.newPlot('levels_per_assignment', data, layout, {displayModeBar: false});
}
