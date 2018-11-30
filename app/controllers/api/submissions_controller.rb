class API::SubmissionsController < ApplicationController
  def index
    @submissions = current_user_is_staff? ? current_course.submissions.includes(:grade) : current_student.submissions.includes(:grade)
    @submissions = @submissions.submitted if !current_user_is_student? && !current_user_is_admin?
    @submissions = @submissions.for_student(params[:student_ids]) \
      if params[:student_ids].present?
    @submissions = @submissions.for_assignment(params[:assignment_ids]) \
      if params[:assignment_ids].present?
  end
end
