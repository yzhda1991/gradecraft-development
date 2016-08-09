class API::Grades::GradeFilesController < ApplicationController

  before_filter :ensure_staff?

  # POST /api/grades/:grade_id/grade_files
  def create
    grade = Grade.find(params[:grade_id])
    grade.add_grade_files(*params[:grade_files])
    render json: { message: "success uploading grade files"}
  end
end
