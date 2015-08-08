$(document).ready(function() {

    function createOptions () {
    return {
    chart: {
      type: 'bar',
      backgroundColor:null
    },
    colors: [
     '#1A1EB2',
     '#303285',
     '#6dd8f0',
     '#080B74',
     '#00BD39',
     '#238D43',
     '#007B25',
     '#37DE6A',
     '#64DE89',
     '#FFCC00',
     '#BFBD30',
     '#A6A400',
     '#FFFD40',
     '#FFFD73'
  ],

    credits: {
      enabled: false
    },
    xAxis: {
      gridLineWidth: 0,
      lineColor: '#FFFFFF',
      title: {
        text: ' '
      },
      labels: {
        style: {
          color: "#FFF"
        }
      }
    },
    yAxis: {
      gridLineWidth: 1,
      lineColor: '#FFFFFF',
      min: 0,
      title: {
        text: ' '
      }
    },
    tooltip: {
      formatter: function() {
        return '<b>'+ this.series.name +'</b><br/>'+
        this.y + ' points';
      }
    },
    plotOptions: {
      series: {
        stacking: 'normal',
        borderWidth: 0,
        pointWidth: 40,
        events: {
          legendItemClick: function () {
              return false; 
          }
        }
      }
    },
    legend: {
      enabled: false
    }
  };
  }

    var chart, categories, assignment_type_name, scores, grade_levels;
    if ($('#userBarTotal').length) {
      var data = JSON.parse($('#data-predictor').attr('data-predictor'));

      var options = createOptions()
      options.chart.renderTo = 'userBarTotal';
      options.title = { text: '', margin: 0 };
      options.xAxis.categories = { text: ' ' };
      options.yAxis.max = data.course_total;
      options.yAxis.plotBands = data.grade_levels;
      options.series = data.scores;
      chart = new Highcharts.Chart(options);
    };
});
