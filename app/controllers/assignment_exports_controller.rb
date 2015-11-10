class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?

  respond_to :json

  def submissions
    @assignment_export_job = AssignmentExportJob.new({
      assignment_id: params[:assignment_id],
      professor_id: current_user.id
    })
    @job_enqueued = @assignment_export_job.enqueue
    render submissions_response
  end

  def team_submissions
    @assignment_export_job = AssignmentExportJob.new({
      assignment_id: params[:assignment_id],
      professor_id: current_user.id,
      team_id: params[:team_id]
    })
    @job_enqueued = @assignment_export_job.enqueue
    render submissions_response
  end

  protected

  def submissions_response
    if @job_enqueued
      { status: 200, json: "Your archive is being prepared. You'll receive an email when it's complete." }
    else
      { status: 400, json: "Your archive failed to build. An administrator has been contacted about the issue." }
    end
  end
end
