$(function() {
  $(document).on("click", "[data-behavior~=toggle-course-setting]", function(e) {
    e.preventDefault();
    var target = $(e.target);
    var course = target.parents(".course-selection");
    var setting = course.find(".course-setting");
    setting.slideToggle(100, function() {
      var index = setting.find("input[name=child_index]").val();
      var destroy = setting.find("#user_course_memberships_attributes_" + index + "__destroy");
      destroy.val(setting.is(":hidden"));
      course.find("h4 .button").hide();
      if (setting.is(":hidden")) {
        course.find("h4 .button").not(".danger").show();
      } else {
        course.find("h4 .button.danger").show();
      }
    });
  });
});
