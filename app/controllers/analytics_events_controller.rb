class AnalyticsEventsController < ApplicationController
  skip_before_filter :increment_page_views

  def predictor_event
    # limited to 5 predictor jobs/second in Resque initializer
    Resque.enqueue(PredictorEventLogger, "predictor",
                                course_id: current_course.id,
                                user_id: current_user.id,
                                student_id: current_student.try(:id),
                                user_role: current_user.role(current_course),
                                assignment_id: params[:assignment].to_i,
                                score: params[:score].to_i,
                                possible: params[:possible].to_i,
                                created_at: Time.now
                                )
    render :nothing => true, :status => :ok
  end

  def tab_select_event
    # limited to 2 predictor jobs/second in Resque initializer
    Resque.enqueue_in(Lull.time_until_next_lull, PageviewEventLogger, "pageview",
                              course_id: current_course.id,
                              user_id: current_user.id,
                              student_id: current_student.try(:id),
                              user_role: current_user.role(current_course),
                              page: "#{params[:url]}#{params[:tab]}",
                              created_at: Time.zone.now
                              )
    render :nothing => true, :status => :ok
  end
end
