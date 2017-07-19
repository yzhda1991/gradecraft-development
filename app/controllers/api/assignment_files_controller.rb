# Note: this file has been formatted as similarly to FileUploadsController as
# possible, to facilitate eventually moving AssignmentFiles into this
# polymorphic model, and combining the two controllers.

class API::AssignmentFilesController < ApplicationController

  before_action :ensure_staff?

  # POST /api/assignments/:assignment_id/file_uploads
  def create
    assignment = Assignment.find(params[:assignment_id])

    @file_uploads = []
    params[:file_uploads].each do |f|
      file = assignment.assignment_files.create(
        file: f,
        filename: f.original_filename[0..49]
      )
      @file_uploads << file
    end
    render "api/file_uploads/index", status: 201
  end

  # DELETE /api/assignment_files/:id
  def destroy
    file = AssignmentFile.where(id: params[:id]).first
    if file.present?
      file.delete_from_s3
      file.destroy

      if !file.exists_on_s3? && file.destroyed?
        render json: { message: "Assignment file successfully deleted", success: true },
        status: 200
      elsif file.destroyed?
        render json: {message: "Assignment file deleted, error removing remote file", success: true},
        status: 200
      else
        render json: {message: "Assignment file failed to delete", success: false},
        status: 400
      end
    else
      render json: {message: "Assignment file not found", success: false},
      status: 400
    end
  end
end
