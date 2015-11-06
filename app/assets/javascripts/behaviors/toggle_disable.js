var ToggleDisabled = function() {};

ToggleDisabled.prototype.toggleRecursive = function(el) {
  var $el = $(el);
  var self = this;
  $.each($el, function(index, child) { self.toggle(child); });
};

ToggleDisabled.prototype.toggle = function(el) {
  var $el = $(el);
  console.log($el);
  var disabled = $el.is("input:disabled");
  if ($el.is(":input")) {
    $el.prop("disabled", !disabled);
  } else {
    $el.toggleClass("disabled");
  }
};

$(function() {
  $(document).on("click", "[data-behavior~=toggle-disable]", function(e) {
    var disableTargetSelector = $(e.target).data("toggle-disable-target");
    if (disableTargetSelector) {
      new ToggleDisabled().toggleRecursive(disableTargetSelector);
    }
  });
});
