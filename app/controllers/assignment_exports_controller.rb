class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?

  def create
    @assignment_export_job = AssignmentExportJob.new({
      assignment_id: params[:assignment_id],
      professor_id: current_user.id,
      course_id: current_course.id,
      team_id: params[:team_id]
    })

    @job_enqueued = @assignment_export_job.enqueue
    write_flash_response

  end

  protected

  def write_flash_response
    if @job_enqueued
      flash[:notice] = "Your archive is being prepared. You'll receive an email when it's complete."
    else
      flash[:warning] = "Your archive failed to build. An administrator has been contacted about the issue."
    end
  end
end
