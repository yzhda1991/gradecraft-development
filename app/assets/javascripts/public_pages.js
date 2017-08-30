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

//toggle password forgot form on login page
$('#forgot-password').click(function() {
  $('.password-forgot-form').show().attr('aria-hidden', 'false');
  $('.login-form').hide().attr('aria-hidden', 'true');
});

$('#show-login-form').click(function() {
  $('.login-form').show().attr('aria-hidden', 'false');
  $('.password-forgot-form').hide().attr('aria-hidden', 'true');
});

$('#show-gradecraft-login').click(function() {
  $('.gradecraft-login').show().attr('aria-hidden', 'false');
  $('.login-form').hide().attr('aria-hidden', 'true');
});

$('#show-umich-login').click(function() {
  $('.login-form').show().attr('aria-hidden', 'false');
  $('.gradecraft-login').hide().attr('aria-hidden', 'true');
});
