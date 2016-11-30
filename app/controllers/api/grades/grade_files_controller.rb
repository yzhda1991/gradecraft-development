class API::Grades::GradeFilesController < ApplicationController

  before_action :ensure_staff?

  # POST /api/grades/:grade_id/grade_files
  def create
    grade = Grade.find(params[:grade_id])

    @file_attachments = []
    params[:file_attachments].each do |f|
      file = FileAttachment.create(file: f, filename: f.original_filename[0..49], grade_id: grade.id)
      GradeFile.create(file_attachment_id: file.id, grade_id: grade.id)
      @file_attachments << file
    end

    render status: 201
  end

  # DELETE /api/grades/:grade_id/grade_files/:id
  def destroy
    file = FileAttachment.where(id: params[:id], grade_id: params[:grade_id]).first
    if file.present?
      file.delete_from_s3
      file.destroy

      GradeFile.where(file_attachment_id: file.id).destroy_all

      if !file.exists_on_s3? && file.destroyed?
        render json: { message: "Grade file successfully deleted", success: true },
        status: 200
      elsif file.destroyed?
        render json: {message: "Grade file deleted, error removing remote file", success: true},
        status: 200
      else
        render json: {message: "Grade file failed to delete", success: false},
        status: 400
      end
    else
      render json: {message: "Grade file not found", success: false},
      status: 400
    end
  end
end
