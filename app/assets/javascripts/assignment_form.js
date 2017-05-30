!function($) {

  // Toggle label on:
  //   grades/_standard_edit.html.haml
  $('.pass-fail-grade-toggle :checkbox').click(function(){
    var on = $('.pass-fail-contingent').data("on");
    var off = $('.pass-fail-contingent').data("off");
    $('.pass-fail-grade-toggle :checkbox').prop("checked") ?
      $('.pass-fail-contingent label').text(on) :
      $('.pass-fail-contingent label').text(off);
  });

  // Toggle conditional form elements:
  //   app/views/assignments/_form.haml
  $('.pass-fail-toggle :checkbox').click(function(){
    $('.pass-fail-toggle :checkbox').prop("checked") ?
      $('.pass-fail-contingent').addClass("visually-hidden") :
      $('.pass-fail-contingent').removeClass("visually-hidden");
  });

  $('.individual-group-select select').change(function(){
    if ($(this).val() === "Group") {
      $('.individual-group-contingent').removeClass("visually-hidden");
    }
    else {
      $('.individual-group-contingent').addClass("visually-hidden");
    }
  });

}(jQuery);


//Show and hide conditional form items (used on assignment and badge edit)
function showConditionalOptions($thisInput) {
  var $thisConditionalOptionsList = $thisInput.closest('.form-item-with-options').next('.conditional-options');
  
  if ($thisInput.is(':checked')) {
    $thisConditionalOptionsList.removeClass('visually-hidden');
  } else {
    $thisConditionalOptionsList.addClass('visually-hidden');
  }
}

$('input.has-conditional-options').change(function() {
  showConditionalOptions($(this));
});
