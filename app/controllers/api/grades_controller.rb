class API::GradesController < ApplicationController

  before_filter :ensure_staff?

  # GET api/assignments/:id/student/:student_id/grade
  def show
    @grade = Grade.find_or_create(params[:id],params[:student_id])
  end
end


