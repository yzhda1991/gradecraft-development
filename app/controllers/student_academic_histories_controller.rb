class StudentAcademicHistoriesController < ApplicationController

  before_filter :ensure_staff?

  def index
    @academic_histories = current_course.student_academic_histories
  end

  def show
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.where(:course_id => current_course).first
  end

  def new
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.new
  end

  def create
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.build
  end

  def edit
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.where(:course_id => current_course).first
  end

  def update
    @student = current_course.students.find(params[:id])
    @academic_history.update_attributes(params[:academic_history])
  end

  def destroy
  end

end
