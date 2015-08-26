!function($) {

  $('.pass-fail-toggle :checkbox').click(function(){
    $('.pass-fail-contingent').toggleClass("hidden")
  });


  // Toggle label on:
  //   grades/_standard_edit.html.haml
  //   students/predictor/_assignments.haml

  $('.pass-fail-grade-toggle label').click(function(){
    var on = $('.pass-fail-contingent').data("on");
    var off = $('.pass-fail-contingent').data("off");
    if ($( ".pass-fail-grade-toggle input:checked" ).length > 0) {
      $('.pass-fail-contingent').text(off);
    } else {
      $('.pass-fail-contingent').text(on);;
    };
  });

}(jQuery);
