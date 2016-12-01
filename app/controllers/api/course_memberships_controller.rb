class API::CourseMembershipsController < ApplicationController

  # POST api/course_memberships/confirm_onboarding
  def confirm_onboarding
    course_membership = current_student.course_memberships.where(course_id: current_course.id).first
    course_membership.has_seen_course_onboarding = true
    course_membership.save
    render json: { message: "Onboarding Confirmed", success: true }
  end
end
