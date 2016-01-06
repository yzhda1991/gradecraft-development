class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?

  def create
    if create_assignment_export and assignment_export_job.enqueue
      job_success_flash 
    else
      job_failure_flash
    end

    redirect_to assignment_path(assignment)
  end

  def destroy
    if delete_s3_object
      assignment_export.destroy
      flash[:success] = "Assignment export successfully deleted from server"
    else
      flash[:alert] = "Unable to delete the assignment export from the server"
    end

    redirect_to exports_path
  end

  def download
    send_data assignment_export.fetch_object_from_s3.body.read, filename: assignment_export.export_filename
    render nothing: true
  end

  protected

  def delete_s3_object
    @delete_s3_object ||= assignment_export.delete_object_from_s3
  end

  def assignment_export
    @assignment_export ||= AssignmentExport.find params[:id]
  end
    
  def create_assignment_export
    @assignment_export = AssignmentExport.create(
      assignment_id: params[:assignment_id],
      course_id: current_course.id,
      professor_id: current_user.id,
      team_id: params[:team_id]
    )
  end

  def assignment_export_job
    @assignment_export_job ||= AssignmentExportJob.new assignment_export_id: @assignment_export.id
  end

  def job_success_flash
    flash[:success] = "Your assignment export is being prepared. You'll receive an email when it's complete."
  end

  def job_failure_flash
    flash[:alert] = "Your assignment export failed to build. An administrator has been contacted about the issue."
  end

  def assignment
    @assignment ||= Assignment.find(params[:assignment_id])
  end
end
