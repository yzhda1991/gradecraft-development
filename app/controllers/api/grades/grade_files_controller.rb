class API::Grades::GradeFilesController < ApplicationController

  before_action :ensure_staff?

  # POST /api/grades/:grade_id/grade_files
  def create
    grade = Grade.find(params[:grade_id])

    @grade_files = []
    params[:grade_files].each do |f|
      @grade_files << GradeFile.create(file: f, filename: f.original_filename[0..49], grade_id: grade.id)
    end

    render status: 201
  end

  # DELETE /api/grades/:grade_id/grade_files/:id
  def destroy
    grade_file = GradeFile.where(id: params[:id], grade_id: params[:grade_id]).first
    if grade_file.present?
      grade_file.delete_from_s3
      grade_file.destroy

      if !grade_file.exists_on_s3? && grade_file.destroyed?
        render json: { message: "Grade file successfully deleted", success: true },
        status: 200
      elsif grade_file.destroyed?
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
