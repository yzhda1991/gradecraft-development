module CurrentScopes

  def self.included(base)
    base.helper_method :current_user, :current_course, :current_student
  end

  def current_course
    return unless current_user
    @__current_course ||= CourseRouter.current_course_for(current_user, session[:course_id])
  end

  def current_student
    if current_user_is_student?
      @__current_student ||= current_user
    else
      @__current_student ||= (current_course.students.find_by(id: params[:student_id]) if params[:student_id])
    end
  end

  def current_role
    return unless current_user && current_course
    @__current_role ||= current_user.role(current_course)
  end

  def current_student=(student)
    @__current_student = student
  end

end
