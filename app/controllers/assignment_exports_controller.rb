class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?

  respond_to :json

  def submissions
    @job_enqueued = AssignmentExportJob.new(assignment_id: params[:assignment_id]).enqueue
    respond_with 
  end

  def team_submissions
    @job_enqueued = AssignmentExportJob.new({
      assignment_id: params[:assignment_id],
      team_id: params[:team_id]
    }).enqueue
  end
end
