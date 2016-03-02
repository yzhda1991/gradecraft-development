module PredictorEventJobsToolkit
  def predictor_event_attrs_expectation
    {
      course_id: 50,
      user_id: 70,
      student_id: 90,
      user_role: "great role",
      created_at: Time.parse("Jan 20 1972"),
      prediction_type: "grade",
      assignment_id: 80,
      predicted_points: 9000,
      possible_points: 10000,
      prediction_saved_successfully: true
    }
  end

  def stub_current_user
    @current_user = double(:current_user).as_null_object
    allow(@current_user).to receive_messages(current_course: double(:course))
    allow(controller).to receive_messages(current_user: @current_user)
  end
end
