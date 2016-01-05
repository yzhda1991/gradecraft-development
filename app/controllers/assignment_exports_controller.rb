class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?

  def create
    create_assignment_export
    assignment_export_job.enqueue ? job_success_outcome : job_failure_outcome
    redirect_to assignment_path(assignment)
  end

  def destroy
    fetch_assignment_export

    if delete_s3_object
      @assignment_export.destroy
      flash[:success] = "Assignment export successfully deleted from server"
    else
      flash[:notice] = "Unable to delete the assignment export from the server"
    end

    redirect_to exports_path
  end

  protected

  def delete_s3_object
    @delete_s3_object ||= assignment_export.delete_object_from_s3
  end

  def fetch_assignment_export
    @assignment_export ||= AssignmentExport.find params[:id]
  end
    
  def create_assignment_export
    @assignment_export = AssignmentExport.create({
      assignment_id: params[:assignment_id],
      course_id: current_course.id,
      professor_id: current_user.id,
      team_id: params[:team_id]
    })
  end

  def assignment_export_job
    @assignment_export_job ||= AssignmentExportJob.new({
      assignment_export_id: @assignment_export.id
    })
  end

  def job_success_outcome
    flash[:success] = "Your assignment export is being prepared. You'll receive an email when it's complete."
  end

  def job_failure_outcome
    flash[:alert] = "Your assignment export failed to build. An administrator has been contacted about the issue."
  end

  def assignment
    @assignment ||= Assignment.find(params[:assignment_id])
  end
end
