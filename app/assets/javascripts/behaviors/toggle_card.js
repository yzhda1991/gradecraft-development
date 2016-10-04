$(function() {
  $(document).on("mouseenter", "[data-behavior~=toggle-card]", function(e) {
    var targetSelector = $(e.target).data("target-selector");
    $(targetSelector).show();
  });

  $(document).on("mouseleave", "[data-behavior~=toggle-card]", function(e) {
    var targetSelector = $(e.target).data("target-selector");
    $(targetSelector).hide();
  });
});
