require_relative "../services/cancels_course_membership"

class CourseMembershipsController < ApplicationController

  before_action :ensure_admin?, only: [:index, :delete_many]
  before_action :ensure_staff?
  before_action :save_referer, only: [:destroy]

  def index
    @users = current_course
      .users
      .order("course_memberships.role DESC, last_name, first_name ASC")
      .includes(:course_memberships)
      .where.not(course_memberships: { role: "admin" })
  end

  def create
    @course_membership =
      current_course.course_memberships.create(course_membership_params)
    @course_membership.save

    respond_with @course_membership
    expire_action action: :index
  end

  # Deactivating a student is not the same as destroy. Deactivate will flip the
  # active flag in the record of course membership for the associated user.
  # All the user's records will remain in tact.
  def deactivate
    course_membership = current_course.course_memberships.find(params[:id])
    if course_membership.update active: false
      respond_to do |format|
        format.html { redirect_to students_path, notice: "#{course_membership.user.name} successfully deactivated" }
        format.json { render json: { active: false, success: true }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to students_path, alert: "#{course_membership.user.name} was not updated due to error, please try again" }
        format.json { head :internal_server_error }
      end
    end
  end

  def reactivate
    course_membership = current_course.course_memberships.find(params[:id])
    if course_membership.update active: true
      respond_to do |format|
        format.html { redirect_to students_path, notice: "#{course_membership.user.name} successfully reactivated" }
        format.json { render json: { active: true, success: true }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to students_path, alert: "#{course_membership.user.name} was not updated due to error, please try again" }
        format.json { head :internal_server_error }
      end
    end
  end

  def destroy
    course_membership = current_course.course_memberships.find(params[:id])
    Services::CancelsCourseMembership.call course_membership

    respond_to do |format|
      format.html { redirect_to session[:return_to], notice: "#{course_membership.user.name} was successfully removed from course." }
      format.json { head :ok }
    end
  end

  def delete_many
    CourseMembership.where(id: params[:course_membership_ids]).find_in_batches(batch_size: 50) do |b|
      b.each { |cm| Services::CancelsCourseMembership.call cm }
    end
    redirect_to course_memberships_path,
      flash: { success: "Successfully deleted #{params[:course_membership_ids].count} course membership(s)" }
  end

  private

  def course_membership_params
    params.require(:course_membership).permit :auditing, :character_profile,
      :course_id, :instructor_of_record, :user_id, :role, :last_login_at,
      :earned_grade_scheme_element_id, :has_seen_course_onboarding
  end
end
