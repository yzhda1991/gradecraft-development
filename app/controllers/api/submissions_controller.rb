class API::SubmissionsController < ApplicationController
  before_action :ensure_staff?

  def index
    @submissions = current_course.submissions.includes(:grade)
    @submissions = @submissions.for_student(params[:student_ids]) \
      if params[:student_ids].present?
    submissions = submissions.for_student(params[:student_ids]) if params[:student_ids].present?
    @submissions = @submissions.for_assignment(params[:assignment_ids]) \
      if params[:assignment_ids].present?
  end
end
