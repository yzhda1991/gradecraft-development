//toggle features page sections on public facing site
$('.button-features-toggle').click(function() {
  var btnClicked = $(this);
  var clickedSectionName = ($(this).attr('id').indexOf('student') > -1) ? 'student' : 'instructor';
  var clickedSection = $('.' + clickedSectionName + '-features');

  btnClicked.addClass('selected').attr('aria-pressed', 'true');
  btnClicked.siblings().removeClass('selected').attr('aria-pressed', 'false');
  clickedSection.show().attr('aria-hidden', 'false');
  clickedSection.siblings().hide().attr('aria-hidden', 'true');
});
