module SubmitTagHelper
  # Conditionally renders submit button based on whether the course is active
  def active_course_submit_tag(value = "Save changes", options={})
    submit_tag value, options if current_user_is_admin? || current_course.active?
  end
end
