class SubmissionsExportsController < ApplicationController
  before_filter :ensure_staff?

  def create
    if create_submissions_export and submissions_export_job.enqueue
      job_success_flash 
    else
      job_failure_flash
    end

    redirect_to assignment_path(assignment)
  end

  def destroy
    if delete_s3_object
      submissions_export.destroy
      flash[:success] = "Assignment export successfully deleted from server"
    else
      flash[:alert] = "Unable to delete the assignment export from the server"
    end

    redirect_to exports_path
  end

  def download
    send_data submissions_export.fetch_object_from_s3.body.read, filename: submissions_export.export_filename
  end

  protected

  def delete_s3_object
    @delete_s3_object ||= submissions_export.delete_object_from_s3
  end

  def submissions_export
    @submissions_export ||= SubmissionsExport.find params[:id]
  end
    
  def create_submissions_export
    @submissions_export = SubmissionsExport.create(
      assignment_id: params[:assignment_id],
      course_id: current_course.id,
      professor_id: current_user.id,
      team_id: params[:team_id]
    )
  end

  def submissions_export_job
    @submissions_export_job ||= SubmissionsExportJob.new submissions_export_id: @submissions_export.id
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
