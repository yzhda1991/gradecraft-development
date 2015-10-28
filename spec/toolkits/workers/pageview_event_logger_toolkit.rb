module PageviewEventLoggerToolkit
  def pageview_logger_attrs
    {
      course_id: 50,
      user_id: 70,
      student_id: 90,
      user_role: "great role",
      page: "/a/great/path",
      created_at: Time.parse("Jan 20 1972")
    }
  end

  def stub_current_user
    @current_user = double(:current_user).as_null_object
    allow(@current_user).to receive_messages(default_course: double(:default_course))
    allow(controller).to receive_messages(current_user: @current_user)
  end
end
