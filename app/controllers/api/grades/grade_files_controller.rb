class API::Grades::GradeFilesController < ApplicationController

  before_filter :ensure_staff?

  # POST /api/grades/:grade_id/grade_files
  def create
    grade = Grade.find(params[:grade_id])

    @grade_files = []
    params[:grade_files].each do |f|
      @grade_files << GradeFile.create(file: f, filename: f.original_filename[0..49], grade_id: grade.id)
    end

    render status: 201
  end
end
