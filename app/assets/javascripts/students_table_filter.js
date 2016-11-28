//Filter content on the student index page table for instructors
$('.button-table-action').click(function() {
  var $tableRows = $('.student-index-table tbody tr');
  var btnId = $(this).attr('id');
  var lowestRank = $tableRows.has('.graded').last().find('td:eq(1)').text();

  $(this).addClass("selected").siblings().removeClass("selected");
  $tableRows.show();
  $tableRows.filter(function() {
    var rank = $(this).find('td:eq(1)').text();

    switch(btnId) {
      case 'btn-leaderboard':
        return !rank.length;
      case 'btn-top10':
        return (rank.length) ? parseInt(rank) > 10 : true;
      case 'btn-bottom10':
        return (rank.length) ? parseInt(rank) <= parseInt(lowestRank) - 10 : true;
      case 'btn-flagged-students':
        var flagged = $(this).find('td:eq(0) i').hasClass('flagged');
        return !flagged;
      case 'btn-auditors':
        return rank.length;
    }
  }).hide();
});
