class StudentsController < ApplicationController
  before_action :ensure_staff?
  before_action :save_referer, only: [:recalculate]
  before_action :use_current_course, only: [:index, :show]

  # Lists all students in the course,
  # broken out by those being graded and auditors
  def index
  end

  # Displaying student profile to instructors
  def show
    @events = Timeline.new(@course).events_by_due_date
    self.current_student = @course.students.where(id: params[:id]).first
    redirect_to students_path,
      alert: "That #{(term_for :student).downcase } doesn't seem to be registered for this course" and return unless current_student.present?
    render "show", Info::DashboardCoursePlannerPresenter.build({
      student: current_student,
      assignments: @course.assignments.chronological.includes(:assignment_type, :unlock_conditions),
      course: @course,
      view_context: view_context
    })
  end

  def recalculate
    @student = current_course.students.find_by(id: params[:id])

    # @mz TODO: add specs
    ScoreRecalculatorJob.new(user_id: @student.id,
      course_id: current_course.id).enqueue

    flash[:notice]="Your request to recalculate #{@student.name}'s grade is being processed. Check back shortly!"
    redirect_to session[:return_to] || student_path(@student)
  end
end
