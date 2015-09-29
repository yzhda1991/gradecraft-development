class AnalyticsEventsController < ApplicationController
  skip_before_filter :increment_page_views

  def predictor_event
    # limit to 500 predictor jobs/ minute
    Resque.rate_limit(:predictor_event_logger, at: 500, :per => 60)
    Resque.enqueue(EventLogger, 'predictor',
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
    # limit to 100 pageview jobs/ minute
    Resque.rate_limit(:pageview_event_logger, at: 100, :per => 60) 
    Resque.enqueue(EventLogger, 'pageview',
                              course_id: current_course.id,
                              user_id: current_user.id,
                              student_id: current_student.try(:id),
                              user_role: current_user.role(current_course),
                              page: "#{params[:url]}#{params[:tab]}",
                              created_at: Time.now
                              )
    render :nothing => true, :status => :ok
  end
end
