//
  var sparkOpts = {
    type: 'box',
    width: '80%',
  };

  var $gradeDistro = $('#grade_distro');
  if ($gradeDistro.length) {
    var data = JSON.parse($('#grade_distro').attr('data-scores'));
    if (data !== null) {
      if ($gradeDistro.hasClass('student-distro')) {
        sparkOpts.target = data.user_score[0];
      }
      sparkOpts.disableTooltips = true;
      sparkOpts.height = '35';
      sparkOpts.targetColor = "#FF0000";
      sparkOpts.boxFillColor = '#eee';
      sparkOpts.lineColor = '#444';
      sparkOpts.boxLineColor = '#444';
      sparkOpts.whiskerColor = '#444';
      sparkOpts.outlierLineColor = '#444';
      sparkOpts.outlierFillColor = '#F4A425';
      sparkOpts.spotRadius = '10';
      sparkOpts.medianColor = '#0D9AFF';
      $('#grade_distro').sparkline(data.scores, sparkOpts);
    }
  }
