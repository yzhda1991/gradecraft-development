$(function() {
  $(document).on("click", "[data-behavior~=turn-on]", function(e) {
    var turnOnTargetSelector = $(e.target).data("turn-on-target");
    if (turnOnTargetSelector) {
      var $el = $(turnOnTargetSelector);
      if ($el.is(":checkbox")) {
        $el.prop("checked", true);
      }
    }
  });
});
