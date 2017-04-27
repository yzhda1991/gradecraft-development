!function($) {

  // Toggle label on:
  //   app/views/assignments/_form.haml
  $('.pass-fail-toggle :checkbox').click(function(){
    $('.pass-fail-toggle :checkbox').prop("checked") ?
      $('.pass-fail-contingent').addClass("hidden") :
      $('.pass-fail-contingent').removeClass("hidden");
  });


  // Toggle label on:
  //   grades/_standard_edit.html.haml
  $('.pass-fail-grade-toggle :checkbox').click(function(){
    var on = $('.pass-fail-contingent').data("on");
    var off = $('.pass-fail-contingent').data("off");
    $('.pass-fail-grade-toggle :checkbox').prop("checked") ?
      $('.pass-fail-contingent label').text(on) :
      $('.pass-fail-contingent label').text(off);
  });
  
  $('.individual-group-select select').change(function(){
    if ($(this).val() === "Group") {
      $('.individual-group-contingent').removeClass("hidden");
    }
    else {
      $('.individual-group-contingent').addClass("hidden");
    }
  })

}(jQuery);
