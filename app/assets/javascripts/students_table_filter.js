// //Filter content on the student index page table for instructors

if($('#student-index-table').length > 0 ) {

  var studentIndexDynatable = $('#student-index-table')
    .bind('dynatable:init', function(e, dynatable) {
      dynatable.sorts.functions["numeric"] = numeric;

      // Custom filter logic is defined here:
      dynatable.queries.functions['all-students'] = function(record) {
        return true;
      };
      dynatable.queries.functions['leaderboard'] = function(record) {
        return record.rank.length;
      };
      dynatable.queries.functions['top10'] = function(record) {
        return record.rank.length && parseInt(record.rank) <= 10
      };
      dynatable.queries.functions['bottom10'] = function(record) {
        return record.rank.length && parseInt(record.rank) >
        $('#student-index-table').data()['bottom10Cutoff']
      };
      dynatable.queries.functions['flagged-students'] = function(record) {
        return $(record.flag).find("i").hasClass("flagged");
      };
      dynatable.queries.functions['auditors'] = function(record) {
        return !record.rank.length;
      };
    })
    .dynatable({
      features: {
        paginate: false,
        recordCount: false,
        sorting: false,
        search: true
      },
      dataset: {
        sortTypes: {
          score: 'numeric',
          rank: 'numeric',
        }
      }
    }).data('dynatable');

  var lowestRank = $('#student-index-table tbody tr').has('.graded').last().find('td:eq(1)').text();
  var bottom10Cutoff = lowestRank && parseInt(lowestRank) > 10 ? parseInt(lowestRank) - 10 : 0;
  $('#student-index-table').data('bottom10Cutoff', bottom10Cutoff);

  var removeStudentIndexFilters = function() {
    studentIndexDynatable.queries.remove('leaderboard');
    studentIndexDynatable.queries.remove('top10');
    studentIndexDynatable.queries.remove('bottom10');
    studentIndexDynatable.queries.remove('flagged-students');
    studentIndexDynatable.queries.remove('auditors');
  }

  $('.button-table-action').click( function() {
    $(this).addClass("selected").attr("aria-pressed", "true").siblings().removeClass("selected").attr("aria-pressed", "false");
    var btnId = $(this).attr('id');
    removeStudentIndexFilters();
    studentIndexDynatable.queries.add(btnId.replace('btn-',''));
    studentIndexDynatable.process();
  });

  //start by hiding auditors in table since default button selected is leaderboard
  studentIndexDynatable.queries.add('leaderboard');
  studentIndexDynatable.process();
}



