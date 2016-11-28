//Filter content on the student index page table for instructors
$('.button-table-action').click(function() {
  var $tableRows = $('.student-index-table tbody tr');
  var btnId = $(this).attr('id');
  var lowestRank = $tableRows.last().find('td:eq(1)').text();

  $(this).addClass("selected").siblings().removeClass("selected");
  $tableRows.show();
  $tableRows.filter(function() {
    var rank;

    if (btnId === 'btn-top10') {
      rank = $(this).find('td:eq(1)').text();
      if (rank.length) {
        return parseInt(rank) > 10;
      }
      return true;
    } else if (btnId === 'btn-bottom10') {
      rank = $(this).find('td:eq(1)').text();
      if (rank.length) {
        return parseInt(rank) <= parseInt(lowestRank) - 10;
      }
      return true;
    } else if (btnId === 'btn-flagged-students') {
      var flagged = $(this).find('td:eq(0) i').hasClass('flagged');
      return !flagged;
    } else if (btnId === 'btn-auditors') {
      var auditor = $(this).find('td:eq(0) span').hasClass('auditor');
      return !auditor;
    } else if (btnId === 'btn-leaderboard') {
      var graded = $(this).find('td:eq(0) span').hasClass('graded');
      return !graded;
    }
  }).hide();
});
