class Assignments::StudentsController < ApplicationController
  before_filter :ensure_staff?

  def grade
    grade = Grade.find_or_create params[:assignment_id], params[:student_id]
    redirect_to edit_grade_path grade
  end
end
