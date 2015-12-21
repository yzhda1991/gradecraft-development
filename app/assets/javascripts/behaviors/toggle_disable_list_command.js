$(function() {
  $(document).on("change", "[data-behavior~=toggle-disable-list-command]", function(e) {
    var commandButtonsSelector = $(e.target).data("commands");
    var commandButtons = $(e.target).closest(commandButtonsSelector);
    console.log(commandButtons.length);
  });
});
