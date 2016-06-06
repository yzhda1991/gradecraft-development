require_relative "../services/cancels_course_membership"

class CourseMembershipsController < ApplicationController
  before_filter :ensure_staff?

  def create
    @course_membership =
      current_course.course_memberships.create(params[:course_membership])
    @course_membership.save

    respond_with @course_membership
    expire_action action: :index
  end

  def destroy
    course_membership = current_course.course_memberships.find(params[:id])
    Services::CancelsCourseMembership.for_student course_membership

    redirect_to students_path,
      notice: "#{course_membership.user.name} was successfully removed from course."
  end
end
