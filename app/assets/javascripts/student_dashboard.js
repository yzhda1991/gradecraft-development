$(document).ready(function() {

    function createOptions () {
    return {
    chart: {
      type: 'bar',
      backgroundColor: null
    },
    colors: [
     '#48BDEB',
     '#8BDEFF',
     '#E7F8FF',
     '#1C7200',
     '#68A127',
     '#7CC02F',
     '#EFFFED',
     '#F1592A',
     '#F7941E',
     '#FCB040',
     '#FFCF06',
     '#FFFD73',
     '#1E267F',
     '#1460AE'
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
      },
      labels: {
        style: {
          color: "#FFF"
        }
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
