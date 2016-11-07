//toggle features page sections on public facing site
$('.button-features-toggle').click(function() {
  var btnClicked = $(this);
  var clickedSectionName = ($(this).attr('id').indexOf('student') > -1) ? 'student' : 'instructor';
  var clickedSection = $('.' + clickedSectionName + '-features');

  btnClicked.addClass('selected');
  btnClicked.siblings().removeClass('selected');
  clickedSection.show();
  clickedSection.siblings().hide();
});
