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
    @academic_history = @student.student_academic_histories.new
    if @academic_history.save
      flash[:notice] =  "#{@student.name}'s Academic History profile was successfully created"
      redirect_to student_path(@student)
    else
      render :new
    end
  end

  def edit
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.where(:course_id => current_course).first
  end

  def update
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.where(:course_id => current_course).first
    @academic_history.update_attributes(params[:academic_history])

    if @academic_history.save
      flash[:notice] =  "#{@student.name}'s Academic History profile was successfully updated"
      redirect_to student_path(@student)
    else
      render :edit
    end
  end

  def destroy
    @student = current_course.students.find(params[:id])
    @academic_history = @student.student_academic_histories.where(:course_id => current_course).first
    @academic_history.destroy

    respond_to do |format|
      format.html { redirect_to student_path(@student), notice: "#{@student.name}'s Academic History Profile was successfully deleted" }
      format.json { head :ok }
    end
  end

end
