//toggle features page sections on public facing site
$('.button-features-toggle').click(function() {
  var btnId = $(this).attr('id');
  var $studentFeatBtn = $('#student-feat-btn');
  var $instructorFeatBtn = $('#instructor-feat-btn');
  var $studentSection = $('.student-features');
  var $instructorSection = $('.instructor-features');

  if (btnId === 'student-feat-btn') {
    $instructorFeatBtn.removeClass("selected");
    $studentFeatBtn.addClass("selected");
    $studentSection.show();
    $instructorSection.hide();
  } else {
    $studentFeatBtn.removeClass("selected");
    $instructorFeatBtn.addClass("selected");
    $instructorSection.show();
    $studentSection.hide();
  }
});
