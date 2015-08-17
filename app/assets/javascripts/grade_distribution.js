//
  var sparkOpts = {
    type: 'box',
    width: '80%',
  };
  
  if ($('#student_grade_distro').length) {
    var data = JSON.parse($('#student_grade_distro').attr('data-scores'));
    if (data !== null) {
      sparkOpts.target = data.user_score[0];
      sparkOpts.tooltipOffsetY = -130;
      sparkOpts.height = '35';
      sparkOpts.tooltipOffsetY = -80;
      sparkOpts.targetColor = "#FF0000";
      sparkOpts.boxFillColor = '#eee';
      sparkOpts.lineColor = '#FFF';
      sparkOpts.boxLineColor = '#FFF';
      sparkOpts.whiskerColor = '#FFF';
      sparkOpts.outlierLineColor = '#FFF';
      sparkOpts.outlierFillColor = '#F4A425';
      sparkOpts.spotRadius = '10';
      sparkOpts.medianColor = '#0D9AFF';
      $('#student_grade_distro').sparkline(data.scores, sparkOpts);
    }
  }

