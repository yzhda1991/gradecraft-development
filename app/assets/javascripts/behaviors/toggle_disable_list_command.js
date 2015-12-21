$(function() {
  $(document).on("change", "[data-behavior~=toggle-disable-list-command]", function(e) {
    var commandButtonsSelector = $(e.target).data("commands");
    var commandButtons = $(document).find(commandButtonsSelector);
    var list = $(document).find("[name='" + $(e.target).attr("name") + "']:checked");
    if (list.length > 0) {
      commandButtons.removeClass("disabled").attr("disabled", false);
    } else {
      commandButtons.addClass("disabled").attr("disabled", true);
    }
  });
});
