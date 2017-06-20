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


//toggle change password form on account settings page
$('#update-password').click(function(event) {
  event.preventDefault();
  $('.update-password-form').show().attr('aria-hidden', 'false');
  $(this).hide().attr('aria-hidden', 'true');
});

$('#cancel-password-change').click(function(event) {
  event.preventDefault();
  $('#user_password, #user_password_confirmation').val('');
  $('.update-password-form').hide().attr('aria-hidden', 'true');
  $('#update-password').show().attr('aria-hidden', 'false');
});
