class StudentAcademicHistoriesController < ApplicationController

  before_filter :ensure_staff?

  before_action :find_student

  def show
    @academic_history =
      @student.student_academic_histories.where(course_id: current_course).first
  end

  def new
    @academic_history = @student.student_academic_histories.new
  end

  def create
    @academic_history =
      @student.student_academic_histories.new(student_academic_history_params)
    if @academic_history.save
      flash[:notice] =  "#{@student.name}'s Academic History profile was successfully created"
      redirect_to student_path(@student)
    else
      render :new
    end
  end

  def edit
    @academic_history = @student.student_academic_histories.where(course_id: current_course).first
  end

  def update
    @academic_history = @student.student_academic_histories.where(course_id: current_course).first
    @academic_history.update_attributes(student_academic_history_params)

    if @academic_history.save
      flash[:notice] =  "#{@student.name}'s Academic History profile was successfully updated"
      redirect_to student_path(@student)
    else
      render :edit
    end
  end

  def destroy
    @academic_history = @student.student_academic_histories.where(course_id: current_course).first
    @academic_history.destroy

    respond_to do |format|
      format.html do redirect_to student_path(@student),
          notice: "#{@student.name}'s Academic History Profile was successfully deleted"
      end
    end
  end

  private

  def find_student
    @student = current_course.students.find(params[:student_id])
  end

  def student_academic_history_params
    params.require(:student_academic_history).permit :student_id, :major, :gpa,
      :current_term_credits, :accumulated_credits, :year_in_school, :state_of_residence,
      :high_school, :athlete, :act_score, :sat_score, :course_id
  end

end
